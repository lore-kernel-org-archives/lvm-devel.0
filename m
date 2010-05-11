From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 May 2010 08:36:04 -0400
Subject: [PATCH 0/6] Add infrastructure for cleaner pv handling, v7
Message-ID: <1273581370-13528-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset replaces the last patchset submitted on
Wed, 28 Apr 2010 11:55:37.

>From now on, a user that wants to get/set a PV property and
knows only the pvname must first lookup the vgname, then obtain
a vg handle, and finally use the pv handle to get/set the property.

Early patches add internal functions to lookup a vgname from a device name
and pvid, respecting the order of lookup.  In cases where we lookup by
pvid or there are no mdas, we may need to do increasingly expensive scans
to provide the answer.  Once the internal functions are given, pvchange
is reworked to use this new functionality, and lvm2app interfaces are
added to lookup a vgname from a pvname and pvid, which will be useful
for udisks and other applications that may not know the vgname but want
information on a specific device/PV.  The new functionality is tested by
running the nightly tests and some lvm2app specific tests.


