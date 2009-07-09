From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 18:17:45 -0400
Subject: [PATCH 0/4] Refactor vgremove and move orphan lock inside library calls
Message-ID: <1247177869-12526-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following 4 patches refactor vgremove and move the orphan lock inside
a few library calls.  After these patches we will have vgcreate, vgremove,
and vgextend library calls.

Passes testsuite and applies on:
commit ac959238aadad88428428decc7adcce663589c98
Author: Milan Broz <mbroz@redhat.com>
Date:   Thu Jul 9 11:29:41 2009 +0000

    Fix and precise metadata read errors for segment areas.


