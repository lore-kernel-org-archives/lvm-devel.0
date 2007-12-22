From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Sat, 22 Dec 2007 02:00:49 -0500
Subject: [PATCH 3/3] lvconvert mirror to wait for sync completion and remove temporary mirrors
Message-ID: <476CB621.5060601@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With this patch, like pvmove, lvconvert mirror will
wait for sync completion, showing progress periodically,
and remove the temporary mirror after the completion.

If you don't like lvconvert to wait for sync completion,
use '--background' option. '--interval <sec>' option is also
available like pvmove.

If you stop lvconvert command, you can restart the polling
daemon with 'lvconvert <LV name>'.

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvconvert-polldaemon.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20071222/b234928f/attachment.ksh>
