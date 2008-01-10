From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 10 Jan 2008 16:48:41 -0500
Subject: LVM2 ./WHATS_NEW lib/config/defaults.h
In-Reply-To: <20080110192508.1366.qmail@sourceware.org>
References: <20080110192508.1366.qmail@sourceware.org>
Message-ID: <478692B9.3040708@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

agk at sourceware.org wrote:
> Log message:
> 	Add lv_convert field to default lvs output.
..
>> -#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,origin,snap_percent,move_pv,mirror_log,copy_percent"
>> +#define DEFAULT_LVS_COLS "lv_name,vg_name,lv_attr,lv_size,origin,snap_percent,move_pv,mirror_log,copy_percent,lv_convert"

# lvs -a
..
  Unrecognised field: lv_convert

The field name is 'convert_lv'.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-convert_lv-field.patch
Type: text/x-patch
Size: 1586 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080110/657bf632/attachment.bin>
