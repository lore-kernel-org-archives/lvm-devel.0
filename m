From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Jun 2010 14:06:34 +0200
Subject: [PATCH] Fix clvmd init script status
In-Reply-To: <1277292607-29658-1-git-send-email-mbroz@redhat.com>
References: <1277292607-29658-1-git-send-email-mbroz@redhat.com>
Message-ID: <4C21F8CA.1060205@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.6.2010 13:30, Milan Broz napsal(a):
> - s/Active clustred VG/clustered VG/ (only LV can be active)
>
> - print only active LVs (not all) in status command
> (In the lvdisplay form /dev/vg/lv.)
>
> For now, still use awk (already used in clustered_vgs).
>
> https://bugzilla.redhat.com/show_bug.cgi?id=598495
> ---
>   scripts/clvmd_init_red_hat.in |   11 ++++++-----
>   1 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
> index 1a03984..da09a34 100644


Ack

Future version should be probably able to decode everything using just one 
scan commmand.

Zdenek


