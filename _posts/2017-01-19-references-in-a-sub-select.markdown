---
author: al
comments: true
date: 2017-01-19 21:14:25+00:00
layout: post
link: https://blog.lnx.cx/2017/01/19/references-in-a-sub-select/
slug: references-in-a-sub-select
title: References in a sub-select
wordpress_id: 983
categories:
- /dev/null
---

Have you ever had a sub-select where you really needed to reference a value in the outer query?  I know I have!  The naive way would be to run the outer query and then loop over the results running the inner query on each one.  Luckily, there's a better way.  The [Correlated subquery](https://en.wikipedia.org/wiki/Correlated_subquery).  Check it out!  The example given is 

`
    
    
    SELECT employee_number, name
      FROM employees AS Bob
      WHERE salary > (
        SELECT AVG(salary)
          FROM employees
          WHERE department = Bob.department);
    

`

See how the sub-select references the outer query?  It's SQL magic.
