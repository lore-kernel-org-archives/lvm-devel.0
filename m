From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:34:12 +0100
Subject: [PATCH 22/30] Fix constness warning
In-Reply-To: <f5ad4e42db829b60ebb0eebadb463720b43b0d71.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<f5ad4e42db829b60ebb0eebadb463720b43b0d71.1287994530.git.zkabelac@redhat.com>
Message-ID: <877hh65zob.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:29 +0200,
Zdenek Kabelac wrote:
> 
> Fix usage of const 'data' pointer and also assign void* directly without
> uneeded cast for C.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack


