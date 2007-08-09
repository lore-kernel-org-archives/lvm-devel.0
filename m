From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 09 Aug 2007 14:23:57 -0400
Subject: [LVM2 PATCH] Add lv_is_internal() to check internal LVs
In-Reply-To: <46BB5526.5030706@ce.jp.nec.com>
References: <46BB5526.5030706@ce.jp.nec.com>
Message-ID: <46BB5BBD.9080705@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jun'ichi Nomura wrote:
> Attached patch adds lv_is_internal() to check internal LVs.
> lv_is_visible() returns true for "snapshotX" so it can't
> directly usable for this purpose.

Oops, sorry. I posted a wrong patch.

> +int lv_is_internal(const struct logical_volume *lv)
> +{
> +	if (lv->status & SNAPSHOT)
> +		return 0;
> +
> +	return lv_is_visible(lv);
> +}

The return value is apparently inverted here.
Internal LVs are either:
  - snapshot (i.e. "snapshotX")
  - not visible

Resending the correct patch.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-add-lv_is_internal.patch
Type: text/x-patch
Size: 3163 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070809/1c493535/attachment.bin>
