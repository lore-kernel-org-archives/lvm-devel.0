From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 30 Jan 2008 20:32:59 -0500
Subject: [PATCH 2/2] Add a test script for mirror LV namings
Message-ID: <47A1254B.3010900@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds a test to check the naming convention of mirror LV.
  - Mirror images have "_mimage_<n>" suffix
  - Mirror log has "_mlog" suffix
  - Temporary LV has "_mimagetmp_<n>" suffix
  - lvrename renames all sub LVs

Temporary mirror log should have "_mlogtmp_<n>" suffix
but currently lvconvert doesn't have an option to add the log.
If such feature is added in future, a test for that should
be added.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: add-lvconvert-check-names.patch
Type: text/x-patch
Size: 5994 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080130/c7a0b595/attachment.bin>
