From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:51:11 +0000
Subject: [PATCH 25/29] Check for unlink result
In-Reply-To: <6022829a3292ffcc95debee81bda60e0522698e2.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<6022829a3292ffcc95debee81bda60e0522698e2.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129215111.GO29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:29AM +0100, Zdenek Kabelac wrote:
> +	if (unlink(path))
> +		log_debug("Unlink %s failed: %s", path, strerror(errno));

log_sys_debug ?

Alasdair


