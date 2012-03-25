From: Milan Broz <mbroz@redhat.com>
Date: Sun, 25 Mar 2012 23:00:56 +0200
Subject: [PATCH 3/4] Do not allow pvmove if some affected LVs are activated locally or on more nodes while others are activated exclusively.
In-Reply-To: <1ff1b02db7ebd97baedb71f806852763be322037.1332708600.git.mbroz@redhat.com>
References: <cover.1332708600.git.mbroz@redhat.com>
	<1ff1b02db7ebd97baedb71f806852763be322037.1332708600.git.mbroz@redhat.com>
Message-ID: <4F6F8788.7010208@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/25/2012 10:56 PM, Milan Broz wrote:
> Current pvmove code can either use local mirror (for exclusive
> activation) or cmirror (for clustered LVs).
>
> Because the whole intenal pvmove LV is just segmented LV containing
> segments of several top-level LVs, code cannot properly handle
> situation if some segment need to be activated exclusively.
>
> Previously, it wrongly activated exclusive LV on all nodes
> (locing code allowed it) but now this is no lnger possible.
>
> If there is exclusively activated LV, pvmove is only
> possible if all affected LVs are aslo activated exclusively.
>
> (Note that in non-exclusive mode pvmove still activates LVs
> on other nodes during move.)
>
> Example - lv1 and lv2 are on sdc:
>    Error locking on node bar-01: Device or resource busy
>    Error locking on node bar-03: Volume is busy on another node
> ...
>    Failed to activate lv2

Ehm. git commented out all lines starting # :-)

It should be read:

Example - lv1 and lv2 are on sdc:

# lvchange -aly vg_test/lv1
# lvchange -aey vg_test/lv2
# pvmove -i 1 /dev/sdc
   Error locking on node bar-01: Device or resource busy
   Error locking on node bar-03: Volume is busy on another node
...
   Failed to activate lv2

m.


