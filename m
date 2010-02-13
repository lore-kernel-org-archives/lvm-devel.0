From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 12 Feb 2010 19:51:47 -0500
Subject: [PATCH 0/3] Add infrastructure for cleaner pv handling
Message-ID: <1266022310-19859-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset adds some infrastructure to move us more towards the
goal of removing the standalone PV object.

>From now on, a user that wants to get/set a PV property and
knows only the pvname must first lookup the vgname, then obtain
a vg handle, and finally use the pv handle to get/set the property.

The last patch reworks pvchange to use this new functionality.
It passes the testsuite but does still have one bug.  A
setup with a VG containing a PV with metadatacopies == 0 and
pvchange -u --all end up failing because the PV is on both the
orphan VG and the real VG.  I think this is a bug internally
unrelated to this patchset but I have yet to track it down.
It should be fixed before we move the tools to this new method.


