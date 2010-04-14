From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 14 Apr 2010 11:20:57 -0400
Subject: [PATCH 0/2] Change lvm2app memory allocation for pv/vg/lv properties
Message-ID: <1271258459-14505-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset changes memory allocation for pv/vg/lv properties in lvm2app.
Unfortunately, this is a change to the existing API, but has the following
benefits:
1) gives us consistency in memory handling across the API (lvm2app
allocs/frees memory for strings and lists).
2) allows for simpler application code

A few downsides of this approach:
1) an application that repeatedly calls a 'get' property function will
generate repeated allocations and could eventually trigger an OOM,
as the only way to release memory is to release the vg handle.  Possible
fixes to this situation include the application release and reacquire
the vg handle, or lvm2app provide another API to release object property
memory tied to a vg handle (internally this would require a separate
memory pool for the attribute memory).  In any case, there are workarounds
possible for this downside.
2) An application may hold a vg handle open longer than it would previously.
This would mean an application would hold a lock longer than it might have
had lvm2app given the application control of the memory.  This is really
an application issue though, since the application can simply copy memory
properties it might need and release the vg handle.


