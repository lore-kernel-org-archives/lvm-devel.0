From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 Jan 2011 13:51:00 +0000
Subject: [PATCH 6/8] Add internal fs cookie
In-Reply-To: <c1ecd1ab7967504239b8258ad0bb2517fa4314a5.1294398815.git.zkabelac@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
	<c1ecd1ab7967504239b8258ad0bb2517fa4314a5.1294398815.git.zkabelac@redhat.com>
Message-ID: <20110107135100.GG5910@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 07, 2011 at 12:17:34PM +0100, Zdenek Kabelac wrote:
> Add functions for handling internal lvm cookie used for
> all dm_tree operations until fs_unlock is called.
 
Ack.

> +		if (!dm_udev_wait(_fs_cookie))

(This function returns succesfully immediately if _fs_cookie still
holds DM_COOKIE_AUTO_CREATE.)

Alasdair


