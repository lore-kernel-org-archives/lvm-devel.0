From: thornber@sourceware.org <thornber@sourceware.org>
Date: 21 Jul 2010 10:00:38 -0000
Subject: LVM2/reports stylesheet.css
Message-ID: <20100721100038.29540.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-21 10:00:38

Modified files:
	reports        : stylesheet.css 

Log message:
	[REPORT-GENERATORS] cut down stylsheet.css to what we actually use

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/reports/stylesheet.css.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/reports/stylesheet.css	2010/07/20 14:38:45	1.1
+++ LVM2/reports/stylesheet.css	2010/07/21 10:00:38	1.2
@@ -1,51 +1,4 @@
-/* I know nothing about css, and am not likely too either since it's
- * about bottom on my list of things to learn.  So this file has been
- * pinched from the Pragmatic Programmers ruby on rails book.  - ejt
- */
-
-/* Global styles */
-
-/* START:notice */
-#notice {
-  border: 2px solid red;
-  padding: 1em;
-  margin-bottom: 2em;
-  background-color: #f0f0f0;
-  font: bold smaller sans-serif;
-}
-/* END:notice */
-
-/* Styles for admin/list */
-
-#product-list .list-title {
-	color:        #244;
-	font-weight:  bold;
-	font-size:    larger;
-}
-
-#product-list .list-image {
-  width:        60px;
-  height:       70px;
-}
-
-
-#product-list .list-actions {
-  font-size:    x-small;
-  text-align:   right;
-  padding-left: 1em;
-}
-
-#product-list .list-line-even {
-  background:   #e0f8f8;
-}
-
-#product-list .list-line-odd {
-  background:   #f8b0f8;
-}
-
-
 /* Styles for main page */
-
 #banner {
   background: #9c9;
   padding-top: 5px;
@@ -73,146 +26,6 @@
   border-bottom: 3px dotted #77d;
 }
 
-/* An entry in the store catalog */
-
-#store  .entry {
-  border-bottom: 1px dotted #77d;
-}
-
-#store  .title {
-  font-size: 120%;
-  font-family: sans-serif;
-}
-
-#store .entry img {
-  width: 75px;
-  float: left;
-}
-
-
-#store .entry h3 {
- margin-bottom: 2px;
- color: #227;
-}
-
-#store .entry p {
- margin-top: 0px;
- margin-bottom: 0.8em;
-}
-
-#store .entry .price-line {
-}
-
-#store .entry .add-to-cart {
-  position: relative;
-}
-
-#store .entry  .price {
-  color: #44a;
-  font-weight: bold;
-  margin-right: 2em;
-}
-
-/* START:inline */
-#store .entry form, #store .entry form div {
-  display: inline;
-}
-/* END:inline */
-
-/* START:cart */
-/* Styles for the cart in the main page and the sidebar */
-
-.cart-title {
-  font: 120% bold;
-}
-
-.item-price, .total-line {
-  text-align: right;
-}
-
-.total-line .total-cell {
-  font-weight: bold;
-  border-top: 1px solid #595;
-}
-
-
-/* Styles for the cart in the sidebar */
-
-#cart, #cart table {
-  font-size: smaller;
-  color:     white;
-}
-
-#cart table {
-  border-top:    1px dotted #595;
-  border-bottom: 1px dotted #595;
-  margin-bottom: 10px;
-}
-/* END:cart */
-
-/* Styles for order form */
-
-.depot-form fieldset {
-  background: #efe;
-}
-
-.depot-form legend {
-  color: #dfd;
-  background: #141;
-  font-family: sans-serif;
-  padding: 0.2em 1em;
-}
-
-.depot-form label {
-  width: 5em;
-  float: left;
-  text-align: right;
-  margin-right: 0.5em;
-  display: block;
-}
-
-.depot-form .submit {
-  margin-left: 5.5em;
-}
-
-/* The error box */
-
-.fieldWithErrors {
-  padding: 2px;
-  background-color: red;
-  display: table;
-}
-
-#errorExplanation {
-  width: 400px;
-  border: 2px solid red;
-  padding: 7px;
-  padding-bottom: 12px;
-  margin-bottom: 20px;
-  background-color: #f0f0f0;
-}
-
-#errorExplanation h2 {
-  text-align: left;
-  font-weight: bold;
-  padding: 5px 5px 5px 15px;
-  font-size: 12px;
-  margin: -7px;
-  background-color: #c00;
-  color: #fff;
-}
-
-#errorExplanation p {
-  color: #333;
-  margin-bottom: 0;
-  padding: 5px;
-}
-
-#errorExplanation ul li {
-  font-size: 12px;
-  list-style: square;
-}
-
 body {
     font: normal 75% verdana,arial,helvetica;
     color:#000000;


