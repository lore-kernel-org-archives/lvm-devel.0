From: Edward Allcutt <emallcut@gleim.com>
Date: Wed, 15 Oct 2008 10:32:38 -0400
Subject: [PATCH] Fix overlap detection in _vg_write_raw()
Message-ID: <48F5FF06.7060704@gleim.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The tests for checking if the new metadata overlaps the old has a flaw.
The amount by which the new metadata wraps is compared to the offset of
the old metadata. However the old metadata offset is from the beginning
of the metadata header whereas new_wrap is from the beginning of the
text area.

My patch fixes this comparison by adding the offset of the text area in
the header to new_wrap.

The first patch[0] applies just this simple fix.

The second alternative patch[1] precomputes the end position of the new
metadata, which simplifies the later comparison. It also extends
new_wrap and old_wrap to uint64_t as all the sizes and offsets used to
calculate them and with which they are compared are already 64-bit.

I've not included the patches directly as I can't convince my MUA not to
wrap the long lines.

[0] - http://allcutt.me.uk/lvm-minimal.diff
[1] - http://allcutt.me.uk/lvm.diff

Thanks to agk for pointing out the location of the bug on IRC.

-- 
Edward Allcutt


