From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 05 Feb 2010 14:34:43 -0600
Subject: [PATCH 0 of 12] LVM add 'mirrored' log type
Message-ID: <1265402083.14189.2.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following set of patches adds the 'mirrored' log type.  It differs
from the last batch by changing the name of the log type
(s/redundant/mirrored/), fixing all the issues uncovered by the
testsuite, adding new test cases, and including log monitoring (provided
by Malahal Naineni).

 brassow



