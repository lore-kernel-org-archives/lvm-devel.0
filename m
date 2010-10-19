From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 19 Oct 2010 09:24:52 -0400
Subject: [PATCH 00/04] Add lvm lvseg properties for lvm2app.
Message-ID: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset adds lvseg_t and lvm_lv_list_lvsegs() API to lvm2app,
then adds lvseg properties and API.  It was created on top of the
following patchset submitted earlier:
http://www.redhat.com/archives/lvm-devel/2010-October/msg00153.html

All lvseg properties are covered by this patch, with the exception of
'seg_pe_ranges' and 'devices'.

This patchset shows the basic approach to enumerating lvsegs, then
querying properties, very similar to the vg, lv, or pv.  Similar
APIs can be made to enumerate and query pvsegs, which would complete
the attribute patchset and allow all properties in the reports to
be queried.


