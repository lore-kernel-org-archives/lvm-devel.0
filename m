Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85360199253
	for <lvm-devel@lists.linux.dev>; Thu, 19 Sep 2024 08:00:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726732861; cv=none; b=CLg8kiHekD0aKyDZggQ9Pd6g+D3rknrYt36g1OsPxYUpe/3+Ubl0w9RWJ8gsYTsugrfFF+BZD1JP4GaTZGiOi7uTgS74HXnjTNudoCnmYkxhQy5wTY0f3/pHHhau1f62Rn8BXLmQGRW1yFbUJ5DpZgE/+/UaroN/VBgKyP3kYQY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726732861; c=relaxed/simple;
	bh=sv639kqPB3178icn6oH6pxcchpaLiDHbrbmTVUOTC/c=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=GR55bb3gmsM99sW7E7QUEXtE03yOR7OdkYtzih7eVrSkhnHi9GqlD7PGlORj98OHIIGzEg0opI/JQ/RWkpJ0wjpjDHMDpaPjvtswmdo/yEBIlrC29echTPO+RResBlq087AL/wfm/ZGX0y1uQXLbd+ZOycM+g2KIPBiJcXW/FOg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=P5WAwWlL; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="P5WAwWlL"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1726732857;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=xpm20v4O8Ha2/jS5nQBaiZT7tGwGq1k62G1cOAOZzRA=;
	b=P5WAwWlLIhnDjiOBMCqUegH/Zpcj5ikCN6j200HtuS5rDUIT1ncKP67+hyPSSiCmxUW8hl
	ex8ITqbVCRCzYFlNG//ygBJssCVr3yWKEhF5XklR1DMq/kQ9rGD4DCeUqydyYWcD8egQ4P
	3nQ62UmvEn02M2h9v+RkjAKxlCadqJA=
Received: from mail-oa1-f69.google.com (mail-oa1-f69.google.com
 [209.85.160.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-688-IFJXPgJzMyKI93aQizefNQ-1; Thu, 19 Sep 2024 04:00:55 -0400
X-MC-Unique: IFJXPgJzMyKI93aQizefNQ-1
Received: by mail-oa1-f69.google.com with SMTP id 586e51a60fabf-27d0e841f08so477506fac.1
        for <lvm-devel@lists.linux.dev>; Thu, 19 Sep 2024 01:00:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726732855; x=1727337655;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=xpm20v4O8Ha2/jS5nQBaiZT7tGwGq1k62G1cOAOZzRA=;
        b=J1akyWZR0ZVTJFP15AwVSgqwWOEM6rYpPb5C4ifw7MJ9Mj/cDLLkSKG2FzVHtVQBkf
         YCjVXSRUWKtSxiVH6bz8h0jllIUNR1F13yLcvY/0ZXVFh3t89Bl3RS5pZo3gqBkScy3l
         ocXjwE7ZhJ4pkV8UAAMAlt1WyR7An5ZhJO9k7xXeTVS8x/ZSiH3NV1ELjPAjUrCoas0w
         YEzObcSj1QunsHmcdWpqhpFxvH15XN/zs9AuMbDk/ktm9rDhRqjS60Qnf1SGIIWEwLcu
         yPv7Rr0ySB5oEpquHeoU/inDe6QcAOa09w2C4TR5Qb5egySBOeb39KEo8rrbBsiklRXI
         6pSg==
X-Forwarded-Encrypted: i=1; AJvYcCU/J9y/p5LTDLGMfjqHH95xb5roIDf2LyywRsP4HEUd48zcmYOzEA4/cpyEX+jELCvZ9qUjaliD39o=@lists.linux.dev
X-Gm-Message-State: AOJu0YyI1B5+K3UT8SZ9asCpENHGpwdnkbVV2q096NMVdGst1VyHIcWw
	0k/c1/DSPS93+XZsFsUioiwHTWQtzH5WeP3OiyWejATFcTNKvhM+M/nHi0gmuchR4keaSmT/Lkl
	1YjE8A2ckh/0VJp5WOU9oBBEPMwrssTMw7S1yvBYKMLAADgZaJfr0DyBLTmrj8wRJlNPCz2slmN
	zt/dic+j4+q4RBXy1yzIKCKPwUDmEyHzH+aEzDFLcuFwYg
X-Received: by 2002:a05:6871:5207:b0:277:caf7:3631 with SMTP id 586e51a60fabf-27c3f2582bamr19365734fac.5.1726732854699;
        Thu, 19 Sep 2024 01:00:54 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IHdrzx1Eg1H+6pO1hKRh9NoIfijdOHUzg2k9/fCcr0Jq5MZcKF2ZL7m7UB9fOCDVTwnIAoI/yD2A9fN4EbC5WQ=
X-Received: by 2002:a05:6871:5207:b0:277:caf7:3631 with SMTP id
 586e51a60fabf-27c3f2582bamr19365713fac.5.1726732854197; Thu, 19 Sep 2024
 01:00:54 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAFe+wq1hQ=jV9bELpm4RXw1=6vPN7hriX0gV6OetNukBEu3ayA@mail.gmail.com>
 <CAHJKXw0uShmYGHvfpFsMGCD-NsEO6DBF8t+pnARimt3SAQfQvg@mail.gmail.com>
In-Reply-To: <CAHJKXw0uShmYGHvfpFsMGCD-NsEO6DBF8t+pnARimt3SAQfQvg@mail.gmail.com>
From: Ming Hung Tsai <mtsai@redhat.com>
Date: Thu, 19 Sep 2024 16:00:43 +0800
Message-ID: <CALjSBEtdzVEY7wtWRa_=Th0VdT73wnPK9-h0YXegoPMGFBojag@mail.gmail.com>
Subject: Re: Reg thin pool activation failure - transaction id mismatch
To: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Cc: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>, lvm-devel@lists.linux.dev
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 18, 2024 at 7:09=E2=80=AFPM Lakshmi Narasimhan Sundararajan
<lns.myspace@gmail.com> wrote:
>
> On Wed, Sep 18, 2024 at 4:25=E2=80=AFPM Lakshmi Narasimhan Sundararajan
> <lsundararajan@purestorage.com> wrote:
> >
> > Hi Team,
> > Good day all!
> >
> > In yet another long testing run, I see a thin pool was unable to get
> > volume group thin pool activated.
> > vgchange -ay <vgname> fails with
> >
> > ```
> > /# vgchange -ay pwx3
> > Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expecte=
d 24.
> > Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expecte=
d 24.
> > Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expecte=
d 24.
> > Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expecte=
d 24.
> > 3 logical volume(s) in volume group "pwx3" now active
> > ```
> > It had other non thin lvols in the vg that got activated successfully.
> >
> > I tried fixing the pool, by trying the following ``` lvconvert
> > --repair pwx3 ``` but this fails to fix the thin pool.
>
> type: this cmd should be "lvconvert --repair pwx3/pxpool" instead
> pointing to the thin pool in the vg.
>
>
> >
> > There was last configuration in the lvm config backup location.
> > I fixed the transaction id and used `vgcfgrestore --force -f <patched
> > config> pwx3` and this fixed the transaction id issue and vg was now
> > successfully activated.
> >
> >
> > And my follow up questions are:
> > 1/ what exactly is a transaction id mismatch problem?
> > A little more detail about this problem will help me understand this be=
tter.
> >

It's a synchronization method between userland lvm and in-kernel
thin-pool metadata. As Zdenek explained, the id increases by one while
you change the thin-pool layout by creating/deleting a thin volume or
snapshot. The transaction id ensures lvm and kernel are working on the
same page.

> > 2/ Are there any known workflows that are known to create this issue?
> > So I can be careful to avoid such workflows.
> >

Did you create or delete thin volumes while running power cycle tests?
The transaction id might be mismatched by one If there's power loss
just right between the kernel updating the transaction id. In older
versions of lvm,  lvm might not catch the discrepancy in transaction
id and then continue on queuing more undeliverable messages, leading
to greater differences in the values. I believe those kinds of issues
have been addressed in recent lvm versions.

> > 3/ does recovery as above guarantee data in the pool? or is the pool
> > data suspect?

It is totally fine if the volume layout (e.g., number of volumes, the
size, and thin_id) matches that of the on-disk metadata.


> > My environment is as below where the problem got seen:
> > ```
> > # uname -a
> > Linux pwx-ocp-240-201-w6d5l-worker-0-zmtns
> > 5.14.0-427.28.1.el9_4.x86_64 #1 SMP PREEMPT_DYNAMIC Fri Jul 19
> > 14:40:47 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
> > ```
> >
> > ```
> > # lvm version LVM version: 2.03.23(2) (2023-11-21) Library version:
> > 1.02.197 (2023-11-21) Driver version: 4.48.0 Configuration:
> > ./configure --build=3Dx86_64-redhat-linux-gnu
> > --host=3Dx86_64-redhat-linux-gnu --program-prefix=3D
> > --disable-dependency-tracking --prefix=3D/usr --exec-prefix=3D/usr
> > --bindir=3D/usr/bin --sbindir=3D/usr/sbin --sysconfdir=3D/etc
> > --datadir=3D/usr/share --includedir=3D/usr/include --libdir=3D/usr/lib6=
4
> > --libexecdir=3D/usr/libexec --localstatedir=3D/var
> > --sharedstatedir=3D/var/lib --mandir=3D/usr/share/man
> > --infodir=3D/usr/share/info --with-default-dm-run-dir=3D/run
> > --with-default-run-dir=3D/run/lvm --with-default-pid-dir=3D/run
> > --with-default-locking-dir=3D/run/lock/lvm --with-usrlibdir=3D/usr/lib6=
4
> > --enable-fsadm --enable-write_install --with-user=3D --with-group=3D
> > --with-device-uid=3D0 --with-device-gid=3D6 --with-device-mode=3D0660
> > --enable-pkgconfig --enable-cmdlib --enable-dmeventd
> > --enable-blkid_wiping --with-udevdir=3D/usr/lib/udev/rules.d
> > --enable-udev_sync --with-thin=3Dinternal --with-cache=3Dinternal
> > --enable-lvmpolld --enable-lvmlockd-dlm --enable-lvmlockd-dlmcontrol
> > --enable-lvmlockd-sanlock --enable-dbus-service --enable-notify-dbus
> > --enable-dmfilemapd --with-writecache=3Dinternal --with-vdo=3Dinternal
> > --with-vdo-format=3D/usr/bin/vdoformat --with-integrity=3Dinternal
> > --with-default-use-devices-file=3D1 --disable-silent-rules
> > --enable-app-machineid --enable-editline --disable-readline
> > ```
> >
> > ```
> > # cat /etc/os-release
> > NAME=3D"Red Hat Enterprise Linux CoreOS"
> > ID=3D"rhcos"
> > ID_LIKE=3D"rhel fedora"
> > VERSION=3D"416.94.202407231922-0"
> > VERSION_ID=3D"4.16"
> > VARIANT=3D"CoreOS"
> > VARIANT_ID=3Dcoreos
> > PLATFORM_ID=3D"platform:el9"
> > PRETTY_NAME=3D"Red Hat Enterprise Linux CoreOS 416.94.202407231922-0"
> > ANSI_COLOR=3D"0;31"
> > CPE_NAME=3D"cpe:/o:redhat:enterprise_linux:9::baseos::coreos"
> > HOME_URL=3D"https://www.redhat.com/"
> > DOCUMENTATION_URL=3D"https://docs.okd.io/latest/welcome/index.html"
> > BUG_REPORT_URL=3D"https://access.redhat.com/labs/rhir/"
> > REDHAT_BUGZILLA_PRODUCT=3D"OpenShift Container Platform"
> > REDHAT_BUGZILLA_PRODUCT_VERSION=3D"4.16"
> > REDHAT_SUPPORT_PRODUCT=3D"OpenShift Container Platform"
> > REDHAT_SUPPORT_PRODUCT_VERSION=3D"4.16"
> > OPENSHIFT_VERSION=3D"4.16"
> > RHEL_VERSION=3D9.4
> > OSTREE_VERSION=3D"416.94.202407231922-0"
> > ```
> >
> > Best regards
> >
>

