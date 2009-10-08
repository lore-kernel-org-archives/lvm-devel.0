From: Petr Rockai <prockai@redhat.com>
Date: Thu, 08 Oct 2009 11:32:45 +0200
Subject: [PATCH 02/13] Replicator: add libdm support
In-Reply-To: <1254751240-17431-2-git-send-email-zkabelac@redhat.com> (Zdenek
	Kabelac's message of "Mon, 5 Oct 2009 16:00:29 +0200")
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
Message-ID: <878wfm9qo2.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Zdenek Kabelac <zkabelac@redhat.com> writes:
>  	case SUSPEND_WITH_LOCKFS:
> -		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1))
> +		if (!dm_tree_suspend_children(root, dlid, ID_LEN + sizeof(UUID_PREFIX) - 1, 0))
other than the API change Alasdair pointed out, this bit here changes existing
behaviour (although it may turn out to not affect anything, it would at least
deserve a comment as to why only priority 0 targets should be suspended).

Please also note that just calling this twice, once for 0 and once for 1 does
not correspond to pre-existing behaviour either (it constitutes an ordering
change).

Yours,
   Petr.


