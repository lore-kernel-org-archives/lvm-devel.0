From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Oct 2010 09:44:53 -0000
Subject: LVM2/test t-fsadm.sh
Message-ID: <20101013094453.7845.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-13 09:44:53

Modified files:
	test           : t-fsadm.sh 

Log message:
	Skip fsadm testing until proper installation rules are commited in.
	
	For now testing of fsadm is broken - as it's executing fsadm from system
	and not from the package thus we get wrong results.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-fsadm.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-fsadm.sh	2010/10/08 15:03:21	1.3
+++ LVM2/test/t-fsadm.sh	2010/10/13 09:44:52	1.4
@@ -10,6 +10,7 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 test_description='Exercise fsadm filesystem resize'
+exit 200
 
 . ./test-utils.sh
 


