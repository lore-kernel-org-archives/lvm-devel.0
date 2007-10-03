From: Jim Meyering <jim@meyering.net>
Date: Wed, 03 Oct 2007 11:51:25 +0200
Subject: [PATCH] trivial build fix: link fsadm against liblvm.a
In-Reply-To: <87642ggisc.fsf@hades.wkstn.nix> (nix@esperi.org.uk's message of
	"Wed, 12 Sep 2007 13:38:59 +0100")
References: <87642ggisc.fsf@hades.wkstn.nix>
Message-ID: <878x6k4jc2.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Nix <nix@esperi.org.uk> wrote:
> Currently it's not, which means that since the introduction of
> last_path_component(), it hasn't built.
>
> Fix is trivial:
>
> Index: lvm/tools/fsadm/Makefile.in
> ===================================================================
> RCS file: /cvs/lvm2/LVM2/tools/fsadm/Makefile.in,v

Thanks.  Applied.


