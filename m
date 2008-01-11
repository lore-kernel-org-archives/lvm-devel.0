From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 11 Jan 2008 18:48:17 -0500
Subject: [PATCH 8/11] Allow "mirror" segment with only 1 area
In-Reply-To: <4787FA27.8050300@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com>
Message-ID: <47880041.4080307@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow "mirror" segment with only 1 area.

As a transitional state, "mirror" segment with only 1 area makes sense
for keeping mirror specific parameters (log_lv, region_size) in metadata.

The segment handler already has a code to add "linear" target line
for table. (see MIRR_DISABLED)

Codes to get copy percent have to consider the segment is in-sync
if area_count is 1.

-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: allow-1way-mirror-seg.patch
Type: text/x-patch
Size: 1990 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080111/c7d0c283/attachment.bin>
