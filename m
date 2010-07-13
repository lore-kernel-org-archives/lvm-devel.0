From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 13 Jul 2010 16:41:34 -0500
Subject: [Patch] Split mirror fixes
In-Reply-To: <1278945011.8025.1.camel@hydrogen.msp.redhat.com>
References: <1278945011.8025.1.camel@hydrogen.msp.redhat.com>
Message-ID: <1E4E0530-AAD5-413A-A04E-B515492A23BA@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Jul 12, 2010, at 9:30 AM, Jonathan Brassow wrote:

> 2) Even though we are grabbing devices to split off from
>   the original mirror from the end of the sub_lv list,
>   why are they the numericly first LVs (i.e lv_mimage_0
>   instead of lv_mimage_3)?  You would expect to have
>   lv_mimage_[01] in your original instead of lv_mimage_[23].
>   Will answer this before checking in the patch - can be
>   answered by gdb and tracking structures...  I also have
>   yet to ensure that this doesn't affect the specification
>   of devices to be removed, since they are shifted to the
>   end of the list before being pulled.

The list was being reordered before the sub-lvs were pulled.  I've  
fixed this in a separate patch.

  brassow


