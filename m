From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:24:26 +0100
Subject: [PATCH 11/30] Fix theoretical usage of NULL pointer dereference
In-Reply-To: <35485b7f7c5850e5a8bd1cb934f7a01efbf6fd46.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<35485b7f7c5850e5a8bd1cb934f7a01efbf6fd46.1287994530.git.zkabelac@redhat.com>
Message-ID: <87eibe604l.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:18 +0200,
Zdenek Kabelac wrote:
> 
> clang seems to be happier with this check.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Nack, this can't happen.  Or rather if it does something has gone badly wrong.  So if (!*c) { stack; return 0; } would be better.


