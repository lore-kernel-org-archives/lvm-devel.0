From: Leo Yan <leo.yan@linaro.org>
Date: Wed, 1 Jul 2020 10:01:06 +0800
Subject: Question: build and install LVM2 on Centos7
In-Reply-To: <2c8b274a-7083-b64b-7f51-433d656bce60@redhat.com>
References: <20200626111614.GC28664@leoy-ThinkPad-X240s>
	<2c8b274a-7083-b64b-7f51-433d656bce60@redhat.com>
Message-ID: <20200701020106.GA10807@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Marian,

On Fri, Jun 26, 2020 at 05:15:25PM +0200, Marian Csontos wrote:

[...]

> > I can manually copy libs from /usr/lib to /usr/lib64 for libdevmapper-*,
> > but seems to me this is not the formal way to do.  My question is how I
> > can smoothly upgrade self built LVM tools on Centos7?
> 
> 
> I think you should just do what rpm macro `%configure` used in EL7 spec file
> does. That expands to rather long statement:
> 
> 
> ./configure --build=x86_64-redhat-linux-gnu --host=x86_64-redhat-linux-gnu
> --program-prefix= --disable-dependency-tracking --prefix=/usr
> --exec-prefix=/usr --bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc
> --datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64
> --libexecdir=/usr/libexec --localstatedir=/var --sharedstatedir=/var/lib
> --mandir=/usr/share/man --infodir=/usr/share/info

Thanks for kindly replying;  It's very useful, I tried it and works
well.  Just note, I also found the macro `%configure` can be read out
with the command 'rpm --eval %configure'.

For the best practice for releasing, I recognized the rpm package might
be a better way to move forward [1].   Will find time to try this as
well.

Thank you for the helping.

Leo

[1] https://www.thegeekstuff.com/2015/02/rpm-build-package-example/


