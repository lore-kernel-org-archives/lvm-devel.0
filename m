From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 5 Dec 2008 12:57:12 +0000
Subject: broken vg after vgconvert -M1
In-Reply-To: <49391424.8090505@aknet.ru>
References: <49391424.8090505@aknet.ru>
Message-ID: <20081205125711.GA26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Dec 05, 2008 at 02:44:36PM +0300, Stas Sergeev wrote:
> I tried to convert my VG to LVM1 format.
> I use lvm2-2.02.33, and vgconvert segfaults.
> Not knowing that the problem is alreay
> fixed in CVS, I made the attached patch.
> The conversion then succeeded, according
> to the vgconvert message, but now I get
> ---
>  Invalid LV in extent map (PV /dev/sdb3, PE 0, LV 0, LE 0)
>  Couldn't fill logical volume maps.
>  Volume group "fedora_vg" not found
> ---
> from any lvm tool.

The error you should have got was:
  Logical volume lvol0 lvid format is incompatible with requested metadata format.
and it should have refused to let you run the vgconvert unless you changed
the UUIDs manually first.

(This is a pretty rare requirement, downgrading the metadata format.)

To recover, you should: update to a newer version such as 2.02.42 or 2.02.43,
find a suitable metadata backup file, edit it to ensure the LV UUIDs are
compatible with LVM1 (ie small consecutive numbers with leading zeroes)
then use vgcfgrestore.

> could lead to the corruption? Could my patch
> be guilty

Yes - in that your metadata was incompatible with LVM1
and the tool previously stopped you from doing the conversion,
albeit by crashing instead of giving you a nice error.
 
Alasdair
-- 
agk at redhat.com


