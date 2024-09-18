Received: from mail-pg1-f171.google.com (mail-pg1-f171.google.com [209.85.215.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D6A7291E
	for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 11:01:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726657272; cv=none; b=gBqOGkxz4Ea0azNffhZ5lauA3hSh0PJmT7taoRt7ra4XJzIYmr8PhDhdr4juiKc/RebFnYZB14wsihDldc2J04pC9FL86OYHfREP1O1zuZb0cKnKop0s5aHeeI00Jv+Rj/RyMWhaiW3W84qLrKAb5UyLAft65RDLbqj7rrTZ3pE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726657272; c=relaxed/simple;
	bh=bq8nm4cLidxFObJ3sxdsTdzCql1j7fe8ZCkWYkLOTZQ=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=n7UFV5QkOnAamCCuP9VSOVyyMNnbNMhWfOHgsA8G71E6Mv5vvj6xbtm7qsO11ofV+mM2X35zDELjx0zlUCf1NJh4aDC1PHEX+9cO5lnKPNDRuxHtuIFXw8NM+xLufaR3Uq99TXtau2+MIjnK6QZhoJqH2HAZ0QHKM7BXFCy4vAs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=FlZHyXpG; arc=none smtp.client-ip=209.85.215.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FlZHyXpG"
Received: by mail-pg1-f171.google.com with SMTP id 41be03b00d2f7-7c1324be8easo558594a12.1
        for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 04:01:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1726657269; x=1727262069; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=bq8nm4cLidxFObJ3sxdsTdzCql1j7fe8ZCkWYkLOTZQ=;
        b=FlZHyXpG+eEfrQgqiYvjnAmDQZwkPtei1KN2Nk5Hj2z6BJlFKpEBvZINfzPfj+22pV
         keqfQ0XXr9Ud/X+FZfhi+MXm+RasZ4ikNxVpsAz21b3fVEWFsV/iHgnRWvdi/kUxcDXj
         hKyqCp4YEU51WpQ+xKAEK7SpW5e81QAUB9mSiqldfwoEmunrJntYwwIYWXicl4dKm+v9
         9QBxToRvkYXyCuS1xUmALLE66qrcQb9rf1A4LuCoRVBkcURE6E5ru85YULLHK/LQ4WjN
         v94Eq4h4nrkPyadePXxTvl2BW9zdaJuXquKDi8l4YGEOun2YgpBHyBTtAnD7nRIBSW+o
         htoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726657269; x=1727262069;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=bq8nm4cLidxFObJ3sxdsTdzCql1j7fe8ZCkWYkLOTZQ=;
        b=JhoCCFP6H2XKs392m/nyCfDUrCN83+OZcmBBBQKp2vTW0vz+Yry1VkE+SdYRJwsrp3
         7Zsw3rsEnZVfg3F42mstL1eQb8klbNFvd1Ke0H4O3InnFOOGEt3rEODXqLC2WtcuiTpp
         KgCyd1rUWmHMepuNP6E8DRk3fUdPTw7TdHos/ig2Il2Mi0P+rRSHi1ZKxsKrehx4ruvC
         VRQXx8YNmbYqyn/8avHFLGD/lrzgQ+O50P8sFZJWJCbf0KZxTOFQv2oNur2aKBC2gaol
         xlhT29N0rgaUQFkoFEsAhEVa3L1fYug2UFAaMf2437+utY5b5B+xPKQiP3D0KrY80B0C
         zofQ==
X-Gm-Message-State: AOJu0YytBd5bfzUoVhtv2PV0qLc9TlfiQbbS7YkdLSDdTj7lba0Wxv9c
	XCOY7biLp2jpNmXloKprENnq/XYkj/czO3oPUaQtN0s9aj6MvBP9RZlPeeIgptWjiPNAklJfcDC
	kweyyoZJoxYXkMKVXXBFeJ8h+L/lXbxo7
X-Google-Smtp-Source: AGHT+IHbNxgcyVQOm5gPSTSZN2SFr2TXVjHYmFjS+1iOTpbJJTNO+i4qJ6pKoX439MrJvVfZ6q+RsFIgxomsFZQHpDk=
X-Received: by 2002:a17:90a:8585:b0:2d8:a744:a81c with SMTP id
 98e67ed59e1d1-2db6717b80dmr42769841a91.1.1726657269183; Wed, 18 Sep 2024
 04:01:09 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAFe+wq1hQ=jV9bELpm4RXw1=6vPN7hriX0gV6OetNukBEu3ayA@mail.gmail.com>
In-Reply-To: <CAFe+wq1hQ=jV9bELpm4RXw1=6vPN7hriX0gV6OetNukBEu3ayA@mail.gmail.com>
From: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Date: Wed, 18 Sep 2024 16:30:54 +0530
Message-ID: <CAHJKXw0uShmYGHvfpFsMGCD-NsEO6DBF8t+pnARimt3SAQfQvg@mail.gmail.com>
Subject: Re: Reg thin pool activation failure - transaction id mismatch
To: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Cc: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 18, 2024 at 4:25=E2=80=AFPM Lakshmi Narasimhan Sundararajan
<lsundararajan@purestorage.com> wrote:
>
> Hi Team,
> Good day all!
>
> In yet another long testing run, I see a thin pool was unable to get
> volume group thin pool activated.
> vgchange -ay <vgname> fails with
>
> ```
> /# vgchange -ay pwx3
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected =
24.
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected =
24.
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected =
24.
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected =
24.
> 3 logical volume(s) in volume group "pwx3" now active
> ```
> It had other non thin lvols in the vg that got activated successfully.
>
> I tried fixing the pool, by trying the following ``` lvconvert
> --repair pwx3 ``` but this fails to fix the thin pool.

type: this cmd should be "lvconvert --repair pwx3/pxpool" instead
pointing to the thin pool in the vg.


>
> There was last configuration in the lvm config backup location.
> I fixed the transaction id and used `vgcfgrestore --force -f <patched
> config> pwx3` and this fixed the transaction id issue and vg was now
> successfully activated.
>
>
> And my follow up questions are:
> 1/ what exactly is a transaction id mismatch problem?
> A little more detail about this problem will help me understand this bett=
er.
>
> 2/ Are there any known workflows that are known to create this issue?
> So I can be careful to avoid such workflows.
>
> 3/ does recovery as above guarantee data in the pool? or is the pool
> data suspect?
>
> My environment is as below where the problem got seen:
> ```
> # uname -a
> Linux pwx-ocp-240-201-w6d5l-worker-0-zmtns
> 5.14.0-427.28.1.el9_4.x86_64 #1 SMP PREEMPT_DYNAMIC Fri Jul 19
> 14:40:47 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
> ```
>
> ```
> # lvm version LVM version: 2.03.23(2) (2023-11-21) Library version:
> 1.02.197 (2023-11-21) Driver version: 4.48.0 Configuration:
> ./configure --build=3Dx86_64-redhat-linux-gnu
> --host=3Dx86_64-redhat-linux-gnu --program-prefix=3D
> --disable-dependency-tracking --prefix=3D/usr --exec-prefix=3D/usr
> --bindir=3D/usr/bin --sbindir=3D/usr/sbin --sysconfdir=3D/etc
> --datadir=3D/usr/share --includedir=3D/usr/include --libdir=3D/usr/lib64
> --libexecdir=3D/usr/libexec --localstatedir=3D/var
> --sharedstatedir=3D/var/lib --mandir=3D/usr/share/man
> --infodir=3D/usr/share/info --with-default-dm-run-dir=3D/run
> --with-default-run-dir=3D/run/lvm --with-default-pid-dir=3D/run
> --with-default-locking-dir=3D/run/lock/lvm --with-usrlibdir=3D/usr/lib64
> --enable-fsadm --enable-write_install --with-user=3D --with-group=3D
> --with-device-uid=3D0 --with-device-gid=3D6 --with-device-mode=3D0660
> --enable-pkgconfig --enable-cmdlib --enable-dmeventd
> --enable-blkid_wiping --with-udevdir=3D/usr/lib/udev/rules.d
> --enable-udev_sync --with-thin=3Dinternal --with-cache=3Dinternal
> --enable-lvmpolld --enable-lvmlockd-dlm --enable-lvmlockd-dlmcontrol
> --enable-lvmlockd-sanlock --enable-dbus-service --enable-notify-dbus
> --enable-dmfilemapd --with-writecache=3Dinternal --with-vdo=3Dinternal
> --with-vdo-format=3D/usr/bin/vdoformat --with-integrity=3Dinternal
> --with-default-use-devices-file=3D1 --disable-silent-rules
> --enable-app-machineid --enable-editline --disable-readline
> ```
>
> ```
> # cat /etc/os-release
> NAME=3D"Red Hat Enterprise Linux CoreOS"
> ID=3D"rhcos"
> ID_LIKE=3D"rhel fedora"
> VERSION=3D"416.94.202407231922-0"
> VERSION_ID=3D"4.16"
> VARIANT=3D"CoreOS"
> VARIANT_ID=3Dcoreos
> PLATFORM_ID=3D"platform:el9"
> PRETTY_NAME=3D"Red Hat Enterprise Linux CoreOS 416.94.202407231922-0"
> ANSI_COLOR=3D"0;31"
> CPE_NAME=3D"cpe:/o:redhat:enterprise_linux:9::baseos::coreos"
> HOME_URL=3D"https://www.redhat.com/"
> DOCUMENTATION_URL=3D"https://docs.okd.io/latest/welcome/index.html"
> BUG_REPORT_URL=3D"https://access.redhat.com/labs/rhir/"
> REDHAT_BUGZILLA_PRODUCT=3D"OpenShift Container Platform"
> REDHAT_BUGZILLA_PRODUCT_VERSION=3D"4.16"
> REDHAT_SUPPORT_PRODUCT=3D"OpenShift Container Platform"
> REDHAT_SUPPORT_PRODUCT_VERSION=3D"4.16"
> OPENSHIFT_VERSION=3D"4.16"
> RHEL_VERSION=3D9.4
> OSTREE_VERSION=3D"416.94.202407231922-0"
> ```
>
> Best regards
>
