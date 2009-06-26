From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 26 Jun 2009 08:22:08 -0400
Subject: [PATCH]: Fix polldaemon background after vg_read patches
Message-ID: <1246018929-30950-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch fixes the t-mirror-lvconvert.sh testcase after the
6 vg_read patches recently posted.  Should apply cleanly on
these patches, and after this all tests should pass.




