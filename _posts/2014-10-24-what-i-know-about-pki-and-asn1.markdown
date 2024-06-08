---
author: al
date: 2014-10-24 18:17:55+00:00
layout: post
title: What I Know About PKI and ASN1
categories:
- Tutorials
tags:
- java
- pki
---

Much of the data in the PKI world is stored in Abstract Syntax Notation One (ASN.1) so a [basic understanding](http://luca.ntop.org/Teaching/Appunti/asn1.html) is necessary. ASN.1 is a way to describe data by starting from primitive types and building up to more complex types. Do you remember Backus-Naur Form? What about writing XML schemas in XSD? It's the same concept.

Let's say we have a Widget. Every Widget has a model name, a serial number, and some inspection information with the name of the inspector and the dates of the inspections. Our Widget then looks like this in ASN.1:

    
    <code class="prettyprint">Widget ::= SEQUENCE {
        model IA5String, 
        serialNumber INTEGER,
        inspections InspectionInfo
    }
    
    InspectionInfo ::= SEQUENCE {
        inspectorName IA5String,
        inspectionDates SEQUENCE OF DATE
    }
    </code>


Now let's go over that. A SEQUENCE is one of the four ASN.1 _structured types_ and it's just an ordered collection of items. Inside that sequence we have an IA5String (International Alphabet 5 -- basically ASCII), an INTEGER, and then an item of InspectionInfo type. We continue down and see InspectionInfo is also a SEQUENCE containing the inspector's name and the inspection dates. The inspection dates are a SEQUENCE OF, another structured type that holds zero or more occurrences of a given type. In this case, the given type is DATE.

There is more to it that I don't understand, but that is enough for the RFCs to make sense.

Now that we have our widget defined, we'll use an ASN.1 library to build a data structure and then write it to DER. DER (Distinguished Encoding Rules) is just a way to encode an object in binary in a [strict, unambiguous manner](http://en.wikipedia.org/wiki/Distinguished_Encoding_Rules#DER_encoding). Alternatively, we can define an ASN.1 structure and decode DER into it.


## DER vs PEM


DER is the ASN.1 data encoded in binary, but DER isn't so great if you need to email a public key to someone for example. The binary is apt to get [screwed up in transit](http://stackoverflow.com/a/201510). So we just take the DER, encode it in Base64 and add on BEGIN and END markers. If you need something in DER, it's as simple as striping off the markers, removing all the newlines, and then Base64 decoding. Do note, however, that OpenSSL can add "headers" to PEM files. For instance, if an RSA private key has been encrypted with DES3, you'll see something like

    
    <code>Proc-Type: 4,ENCRYPTED
    DEK-Info: DES-EDE3-CBC,C0F5225DEC6ADA07
    </code>


before the actual Base64 encoded data. This is weird and from what I can tell non-standard. [Here](https://github.com/bcgit/bc-java/blob/53d17ef/core/src/main/java/org/bouncycastle/util/io/pem/PemReader.java) is how BouncyCastle reads PEM files.


## PKCS Specifications


The [PKCS specifications](http://en.wikipedia.org/wiki/PKCS) are just ways to specify the ASN.1 for different PKI needs. There is a good overview [here](https://polarssl.org/kb/cryptography/asn1-key-structures-in-der-and-pem). If you're ever in doubt, use openssl's [asn1parse](https://www.openssl.org/docs/apps/asn1parse.html) command and it will show you all the gory details.

Let's look at an example. PKCS1 defines the format of public and private RSA keys. OpenSSL outputs the RSA keys it generates in PKCS1 (this example goes for unencrypted keys; encrypted keys are in the non-standard format I mentioned earlier). Now that we know ASN.1, we can decode them. Here is the ASN.1 for RSA private keys in PKCS1:

    
    <code class="prettyprint">RSAPrivateKey ::= SEQUENCE {
        version           Version,
        modulus           INTEGER,  -- n
        publicExponent    INTEGER,  -- e
        privateExponent   INTEGER,  -- d
        prime1            INTEGER,  -- p
        prime2            INTEGER,  -- q
        exponent1         INTEGER,  -- d mod (p-1)
        exponent2         INTEGER,  -- d mod (q-1)
        coefficient       INTEGER,  -- (inverse of q) mod p
        otherPrimeInfos   OtherPrimeInfos OPTIONAL
    }
    
    Version ::= INTEGER { two-prime(0), multi(1) }
        (CONSTRAINED BY {
            -- version must be multi if otherPrimeInfos present --
        })
    
    OtherPrimeInfos ::= SEQUENCE SIZE(1..MAX) OF OtherPrimeInfo
    
    OtherPrimeInfo ::= SEQUENCE {
        prime             INTEGER,  -- ri
        exponent          INTEGER,  -- di
        coefficient       INTEGER   -- ti
    }
    </code>


That's a lot of stuff, but the otherPrimeInfos bit is optional and it's unlikely that we'll care about the version. Here's how we would parse this using [JSS](https://developer.mozilla.org/en-US/docs/JSS) and turn it into a usable Java object:

    
    <code class="prettyprint">private KeyPair readPrivateKey(byte[] der, String password)
        throws CertificateException {
        try {           
            SEQUENCE.Template template = SEQUENCE.getTemplate();
    
            // Create a template for the sequence matching the PKCS1 format
            for (int i = 0; i < 9; i++) {
                template.addElement(INTEGER.getTemplate());
            }
    
            SEQUENCE seq = (SEQUENCE) template.decode(new ByteArrayInputStream(der));
    
            //element 0 is the version which we don't need
            INTEGER mod = (INTEGER) seq.elementAt(1);
            INTEGER pubExp = (INTEGER) seq.elementAt(2);
            INTEGER privExp = (INTEGER) seq.elementAt(3);
            INTEGER p1 = (INTEGER) seq.elementAt(4);
            INTEGER p2 = (INTEGER) seq.elementAt(5);
            INTEGER exp1 = (INTEGER) seq.elementAt(6);
            INTEGER exp2 = (INTEGER) seq.elementAt(7);
            INTEGER crtCoef = (INTEGER) seq.elementAt(8);
    
            rsaKeyFactory = KeyFactory.getInstance("RSA");
            RSAPublicKeySpec pubSpec = new RSAPublicKeySpec(mod, pubExp);
            RSAPrivateCrtKeySpec privSpec = new RSAPrivateCrtKeySpec(
                mod, pubExp, privExp, p1, p2, exp1, exp2, crtCoef);
    
            return new KeyPair(
                rsaKeyFactory.generatePublic(pubSpec),
                rsaKeyFactory.generatePrivate(privSpec));
        }
        catch (Exception e) {
            throw new CertificateException("Could not read private key", e);
        }
    }
    </code>


What does that method do? First it defines a template that matches the PKCS1 ASN.1 (a SEQUENCE of 10 INTEGERs). Then we give the template a byte array and tell it to decode our DER data. Now we have the data in a SEQUENCE and we just pluck out the elements that we care about (in this case all the math stuff). We take the elements and define a [KeySpec](http://docs.oracle.com/javase/7/docs/api/java/security/spec/KeySpec.html) from them. We feed the KeySpec into a KeyFactory and build the KeyPair.


## PKCS12 Keystores


The PKCS12 format is a little more complicated. It defines a way to store a bunch of X509 certs and key pairs all in one file and then have that file encrypted. Thus, these files are often called "keystores". If you are dealing with keystores often (either PKCS12 or the Java alternative, JKS), I recommend a tool called [Portecle](http://portecle.sourceforge.net/). It's a GUI that let's you see everything in a keystore, import or export items, and generate CSRs or import signed certs.

Why do we need a keystore? A freshly installed Fedora machine is only going to have a small list of accepted certificate authorities (CAs). You can either get a certificate that has a chain stretching back to one of these root CAs (like Thawte or Verisign) or you can install an additional CA into the system's list of acceptable CAs. If you opt for the chain of trust approach, then a keystore is a good way of keeping everything in one package.

(On a side note, if you want to install an additional CA into your Fedora machine, drop it in /etc/pki/ca-trust/source/anchors/ and run the `update-ca-trust` command.)


## PKI File Extensions


There are a lot of file extensions for PKI objects: pem, der, csr, key, crt, p12, etc. Naming a file ".pem" is pretty pointless as that only tells you the format and not what the object in the file is. In my opinion, it's best to use extensions that mean something like ".key" for a private key, ".csr" for a certificate signing request, or ".p12" for a PKCS12 keystore.


## Conclusion


Of course there is a lot more to learn about PKI, but hopefully this primer will give you a basic foundation.
