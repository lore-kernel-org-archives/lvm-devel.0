From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Sat, 22 Dec 2007 01:59:25 -0500
Subject: [PATCH 1/3] Fix 'mlogtmp' naming check
Message-ID: <476CB5CD.9060007@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In the previous patchset, _set_up_mirror_log() checks
lv->name to determine whether the mirror log should have
"_mlog" suffix or "_mlogtmp" suffix.
However, it should check the name of mirror image.

Attached patch corrects it.

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: mlogtmp-fix.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071222/274963cd/attachment.ksh>
