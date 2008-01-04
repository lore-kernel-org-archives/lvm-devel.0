From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 04 Jan 2008 10:12:44 -0500
Subject: [PATCH lvconvert 7/11] Fix semantic consistency of mirrorlog option
In-Reply-To: <477E48D8.4050404@ce.jp.nec.com>
References: <477E48D8.4050404@ce.jp.nec.com>
Message-ID: <477E4CEC.3040004@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

'--mirrorlog'/'--corelog' options of lvconvert are used to
add/remove disklog of mirrored LV.
However, it had different meanings for "adding mirrors to mirror",
i.e. the options specify whether to use disklog for conversion.
The patch corrects it.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-semantic-consistency-of-mirrorlog-option.patch
Type: text/x-patch
Size: 2103 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080104/53355b99/attachment.bin>
