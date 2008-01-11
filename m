From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:46:58 -0500
Subject: [PATCH 6/11] Export find_tmp_mirror()
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <4787FFF2.2020209@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Export find_tmp_mirror() for use by lvconvert to
walk down the converting LV stack.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: export-find_tmp_mirror.patch
Type: text/x-patch
Size: 1620 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/34e8d2ed/attachment.bin>
