From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 28 Apr 2010 11:55:37 -0400
Subject: [PATCH 0/5] Add infrastructure for cleaner pv handling
Message-ID: <1272470142-13843-1-git-send-email-dwysocha@redhat.com>
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

The next to last patch reworks pvchange to use this new functionality.

The last patch adds lvm2app interfaces to lookup a vgname from a pvname
and pvid, which will be useful for udisks and other applications that
may not know the vgname but want information on a specific device/PV.



