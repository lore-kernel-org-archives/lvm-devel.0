From: Jim Meyering <jim@meyering.net>
Date: Sat, 23 Feb 2008 09:44:25 +0100
Subject: [PATCH 2/2] Fix lv-seg relationship on layer removal
In-Reply-To: <47BDAF13.4040503@ce.jp.nec.com> (Jun'ichi Nomura's message of
	"Thu, 21 Feb 2008 12:04:19 -0500")
References: <47BDAF13.4040503@ce.jp.nec.com>
Message-ID: <871w74t63a.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

"Jun'ichi Nomura" <j-nomura@ce.jp.nec.com> wrote:
> When removing a layer, segments are moved from the layer LV to
> the original LV (parent).
> Before doing that, call lv_empty() to cleanup the parent and
> any relationships.
>
> Without this, the relationship between the layer_lv and parent remains
> and lvconvert will fail, for example:
>
> # lvconvert -m-1 vg/lvol0
>   LV lvol0_mimagetmp_2 used by LV lvol0:0-511, but is not listed in LV lvol0 segments list.
>   Internal error: LV segments corrupted in lvol0_mimagetmp_2.
>   intermediate VG write failed.

Hi Jun'ichi,

Would you please consider writing (or just outlining) a test case
that fails without yesterday's change, but succeeds with it?

Future maintainers will be grateful :-)


