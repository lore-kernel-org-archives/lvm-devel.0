From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 05 Nov 2010 16:04:49 +0100
Subject: [PATCH 2/3] Add ${prefix}
In-Reply-To: <e9744c088379445ee05a3db39fa75f03b771ad2f.1288706876.git.zkabelac@redhat.com>
References: <cover.1288706876.git.zkabelac@redhat.com>
	<e9744c088379445ee05a3db39fa75f03b771ad2f.1288706876.git.zkabelac@redhat.com>
Message-ID: <4CD41D11.8050705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 2.11.2010 15:10, Zdenek Kabelac napsal(a):
> Avoid files to be written into the live system if lvm was
> configured with diferent --prefix.
> Also put path into one variable initd_dir.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---

Updated version with  initdir defined in make.tmpl.in

Zdenek
-------------- next part --------------
A non-text attachment was scrubbed...
Name: 0002-Add-prefix.patch
Type: text/x-patch
Size: 1622 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101105/ebfd7f40/attachment.bin>
