---
author: al
date: 2015-10-30 20:52:08+00:00
layout: post
title: Streaming the serial numbers from an X509 certificate revocation list
categories:
- Programming
tags:
- asn1
- java
- pki
- x509
---

[The project I work on](http://www.candlepinproject.org) uses X509 certificates with custom extensions to manage content access on the Red Hat CDN. The basic idea is that Candlepin issues X509 certificates with an extension saying what content the certificate is good for. Client systems then use that certificate for TLS client authentication when connecting to the CDN. If the content they are requesting (deduced from the request URL) matches the content available to them in the certificate, then access is granted.

This system works well in practice except for one problem: every time content for a particular product changes, the content data in the X509 extension becomes obsolete. We have to revoke the obsolete certificates and issue new ones. The result is an extremely large certificate revocation list (CRL).

For our cryptography needs, Candlepin uses the venerable [Legion of the Bouncy Castle](http://www.bouncycastle.org) Java library. This library anticipates normal CRL usage so when building a CRL object from an existing file, the entire structure is read into memory at once. This approach doesn't scale well with the numbers of revoked certificates we are dealing with, so we needed to devise a way to stream the CRL. Moreover, the only thing we really care about for our purposes is the revoked certificate's serial number.

Streaming the CRL means we need to dissect the ASN1 that describes the CRL one piece at a time. [RFC 5280](https://tools.ietf.org/html/rfc5280#section-5) to the rescue! Looking at the description of the ASN1 for a CRL reveals that before the sequence containing the revocation entries, there will be a `thisUpdate` and optionally `nextUpdate` field of either type UTCTime or GeneralizedTime. We need to descend in the ASN1 until we get to the `thisUpdate` field, look for and discard the optional `nextUpdate` field and then walk through the `revokedCertificates` sequence reading the serial numbers.

That procedure is not exactly a walk in the park, so in the hope that someone else may find it useful, here is [the solution I came up with](https://github.com/awood/crl-stream/blob/master/src/main/java/org/candlepin/util/X509CRLEntryStream.java). Keep in mind that the code does not check the signature on the CRL so this code should not be used for any CRL that you do not trust implicitly.

The end results are pretty dramatic. The benchmarking toolkit I'm using shows an improvement in execution time by an order of magnitude (from around 7 seconds to .7 seconds) and memory usage drops by about 30%. You can see the GC statistics in the graph below.
[![Visualization of X509CRLStream's benchmarks](https://blog.lnx.cx/wp-content/uploads/2015/10/crl_stream_gc_comparison-200x138.png)](https://blog.lnx.cx/wp-content/uploads/2015/10/crl_stream_gc_comparison.png)

and the benchmarking results are

    
    Benchmark             Mode Cnt    Score     Error  Units
    CRLBenchmark.inMemory avgt  20  7493.602 ± 941.592  ms/op
    CRLBenchmark.stream   avgt  20   669.084 ±  91.382  ms/op
    


In writing this, [A Layman's Guide to a Subset of ASN.1, BER, and DER](http://luca.ntop.org/Teaching/Appunti/asn1.html) was of invaluable assistance to me as was the [Wikipedia page on X.690](https://en.wikipedia.org/wiki/X.690). I recommend reading them both.
