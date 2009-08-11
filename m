From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 11 Aug 2009 10:00:57 -0400
Subject: [PATCH 0/3]: Make all lvm2app handle definitions consistent.
Message-ID: <1249999260-14593-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Currently we have an inconsistency in handle definitions.  The lvm_t
handle is defined as a pointer, but the other handles, vg_t, lv_t, and pv_t
are not.  This patchset makes them all consistent by defining them all as
pointers to internal structures.


