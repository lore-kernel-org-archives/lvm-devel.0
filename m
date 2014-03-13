From: Marian Csontos <mcsontos@redhat.com>
Date: Fri, 14 Mar 2014 00:27:36 +0100
Subject: master - man: add man page for lvm2-activation-generator
In-Reply-To: <20140313120309.6E56060DF2@fedorahosted.org>
References: <20140313120309.6E56060DF2@fedorahosted.org>
Message-ID: <53223EE8.6070201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Peter, this breaks RPM builds, see bellow...

On 03/13/2014 01:03 PM, Peter Rajnoha wrote:
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=031666ef66bf7b17ded4afcaa9bb97587fca0749
> Commit:        031666ef66bf7b17ded4afcaa9bb97587fca0749
> Parent:        c0f1eb5f0f8f0a790d1d9e6d9d3e1323c85e4144
> Author:        Peter Rajnoha <prajnoha@redhat.com>
> AuthorDate:    Thu Mar 13 13:01:06 2014 +0100
> Committer:     Peter Rajnoha <prajnoha@redhat.com>
> CommitterDate: Thu Mar 13 13:01:06 2014 +0100
>
> man: add man page for lvm2-activation-generator
>
> ---
>   Makefile.in                                        |    1 +
>   WHATS_NEW                                          |    1 +
>   man/Makefile.in                                    |   11 +++-
>   man/lvm2-activation-generator.8.in                 |   55 ++++++++++++++++++++
>   .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
>   5 files changed, 67 insertions(+), 3 deletions(-)
>
...

> diff --git a/man/lvm2-activation-generator.8.in b/man/lvm2-activation-generator.8.in
> new file mode 100644
> index 0000000..bd47397
> --- /dev/null
> +++ b/man/lvm2-activation-generator.8.in
> @@ -0,0 +1,55 @@
> +.TH "LVM2-ACTIVATION-GENERATOR" "8" "LVM TOOLS #VERSION#" "Red Hat, Inc" "\""
> +.SH "NAME"
> +lvm2-activation-generator \- generator for systemd units to activate LVM2 volumes on boot
> +.SH SYNOPSIS
> +.B #SYSTEMD_GENERATOR_DIR#/lvm2-activation-generator

        ^ SYSTEMD_GENERATOR_DIR includes DESTDIR. brew fails with:

+ /usr/lib/rpm/check-buildroot
/builddir/build/BUILDROOT/lvm2-2.02.106-0.311.el7.x86_64/usr/share/man/man8/lvm2-activation-generator.8:.B 
/builddir/build/BUILDROOT/lvm2-2.02.106-0.311.el7.x86_64/usr/lib/systemd/system-generators/lvm2-activation-generator
Found '/builddir/build/BUILDROOT/lvm2-2.02.106-0.311.el7.x86_64' in 
installed files; aborting
error: Bad exit status from /var/tmp/rpm-tmp.UfX2SX (%install)

Toook me a while to understand what the message means as I got confused 
by the .B part...



