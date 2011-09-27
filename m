From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 27 Sep 2011 17:39:42 +0200
Subject: [PATCH v3 03/18] fsadm: Add simple configuration file
In-Reply-To: <1317130971-24173-4-git-send-email-lczerner@redhat.com>
References: <1317130971-24173-1-git-send-email-lczerner@redhat.com>
	<1317130971-24173-4-git-send-email-lczerner@redhat.com>
Message-ID: <4E81EE3E.3080005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 27.9.2011 15:42, Lukas Czerner napsal(a):
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> ---
>  scripts/fsadm.sh |   30 ++++++++++++++++++++++++++++++
>  1 files changed, 30 insertions(+), 0 deletions(-)
> 
> diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
> index 58ff0ab..98921d3 100755
> --- a/scripts/fsadm.sh
> +++ b/scripts/fsadm.sh
> @@ -88,6 +88,9 @@ PROCDEVICES="/proc/devices"
>  PROCPARTITIONS="/proc/partitions"
>  NULL="$DM_DEV_DIR/null"
>  
> +CONFIG_PATHS="/etc/fsadm.conf ~/fsadm.conf"
> +CONFIG=
> +


Looks too complicated -  sourcing config file with some defines looks like
better approach here  if you really think it's useful.


Zdenek


