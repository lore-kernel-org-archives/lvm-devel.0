Received: from mail-pj1-f49.google.com (mail-pj1-f49.google.com [209.85.216.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A94D0178376
	for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 10:55:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726656911; cv=none; b=LfeOIoi8cuhLM9Pb9qVOKvKwzlhjrWbcCSFB0DuRg3RKFSJHtO6z1Sa034NyWAJORXNER7fp3CRfWIo+YTWgf133eei5cLcB9tx5bYNV3Iz7A5WVflXnGRg07ZruwZg+DuWpZQ/dIUaPugkiFIGcc5JHl9lqRIG6qcNVwbdsqiE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726656911; c=relaxed/simple;
	bh=KHEXHQF4P2nmo/gDokH2y+mHNSU0cP8JmkqINN4KqQA=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=TuNHyIZGFR5sw1kDKRm3EDr1l/3CrJO82Rx2JXidTnpEWRzbpjQkjAl16olWD4MGxotP9DGnorlrywpMxcGJo+zcG0eKYVQDcvfMbkAYqPu4q+BsHe3tn1e52ISHY93p9r5gZTJMnTskUMjsalD8k+8IjuZ4NGb8Khjew/RcOtQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com; spf=fail smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=PaAnNPra; arc=none smtp.client-ip=209.85.216.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="PaAnNPra"
Received: by mail-pj1-f49.google.com with SMTP id 98e67ed59e1d1-2da55ea8163so4587609a91.1
        for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 03:55:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1726656908; x=1727261708; darn=lists.linux.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=KHEXHQF4P2nmo/gDokH2y+mHNSU0cP8JmkqINN4KqQA=;
        b=PaAnNPrak5jOnb2NhmnyAu2VAK83lOSvPlI8fcUr61MvGDnkf99T05sNgn3rhQ6xYb
         r7qe1sMhqaUHyRNUIYs2FTL8ULLw7rixiR+mz8ZmbYwyYEqp6mxRaToIvY707i87sHnU
         GOT5wHN6bKi4xUu4zXpUMLyyOM1e4a2UssdJn+b4GV+1CQaNmwweA9tRn7WRrsv5W8BZ
         aVmbAe1YneLr/K2sNirjEZM+I5HN8pIGSYeF5xi56xL16V0JBuXFUqWjnDCoZPGk+f/m
         eP+kMNQz2QwOjZL0iJlQnILB1ahiaWcJN54d4y3rSVGrPd2TWxjaPvcYEIffsWaSjD85
         zAkA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726656908; x=1727261708;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=KHEXHQF4P2nmo/gDokH2y+mHNSU0cP8JmkqINN4KqQA=;
        b=DiJB23kR+D0M2uRZBJVl8alpH8QV3tmPzbxFC1+g3fSaEHHkyZkMH5xzzyxb1bbvkW
         ZiuJGnXkgZ+mBREefA/UhuM1K3sH2mS7iVaWb5wrIrWDwt1snoswsuo1+D0exseibeMU
         AEVQhmQ38eZ+4cnShMsUJP27yaGO3pT0BbMs8CfH6/qmgjlJg2et6cnW7WngFNUX+aGJ
         wPgtgLHMIC7T9iTyv+AbJN377HYxXSaLCT8kIa9SGJdHNmiVTN2da1IKM6p8G1bygnuh
         vjlgSbRgs2xawrB2wcWn9s6UAc+KYQQ/hwKgoPw/tCjmRuUlWDny8PwyeHZyK4dScxz0
         YgNQ==
X-Gm-Message-State: AOJu0YxkBiRA0NoPO8Q3e8LpJehbOSBKaanLw/E7383GxKgiYhzFZJUf
	ViIVa6kd42IUfroF1OUwF4YhtUTooDEWmckBz4o0A34xelGTP4WfS7tyqtR6FCNl/vdi1/Hf3+z
	1yQAHSXFaN2tZIWCTsWr0EeDceY0Xwjy2uvDoUzcVsjXVCdwbwUQ=
X-Google-Smtp-Source: AGHT+IHwPwfC1lD3lJehQrVapEQPMNtmJzTnFJqpe10mWRdiINrIcF7IemXn0XLisstnOaQDx+YjJgQ1YPDS8hzDIJ0=
X-Received: by 2002:a17:90b:1804:b0:2d4:924:8891 with SMTP id
 98e67ed59e1d1-2dba008587emr21789623a91.38.1726656908430; Wed, 18 Sep 2024
 03:55:08 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 18 Sep 2024 16:24:57 +0530
Message-ID: <CAFe+wq1hQ=jV9bELpm4RXw1=6vPN7hriX0gV6OetNukBEu3ayA@mail.gmail.com>
Subject: Reg thin pool activation failure - transaction id mismatch
To: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Team,
Good day all!

In yet another long testing run, I see a thin pool was unable to get
volume group thin pool activated.
vgchange -ay <vgname> fails with

```
/# vgchange -ay pwx3
Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
3 logical volume(s) in volume group "pwx3" now active
```
It had other non thin lvols in the vg that got activated successfully.

I tried fixing the pool, by trying the following ``` lvconvert
--repair pwx3 ``` but this fails to fix the thin pool.

There was last configuration in the lvm config backup location.
I fixed the transaction id and used `vgcfgrestore --force -f <patched
config> pwx3` and this fixed the transaction id issue and vg was now
successfully activated.


And my follow up questions are:
1/ what exactly is a transaction id mismatch problem?
A little more detail about this problem will help me understand this better.

2/ Are there any known workflows that are known to create this issue?
So I can be careful to avoid such workflows.

3/ does recovery as above guarantee data in the pool? or is the pool
data suspect?

My environment is as below where the problem got seen:
```
# uname -a
Linux pwx-ocp-240-201-w6d5l-worker-0-zmtns
5.14.0-427.28.1.el9_4.x86_64 #1 SMP PREEMPT_DYNAMIC Fri Jul 19
14:40:47 EDT 2024 x86_64 x86_64 x86_64 GNU/Linux
```

```
# lvm version LVM version: 2.03.23(2) (2023-11-21) Library version:
1.02.197 (2023-11-21) Driver version: 4.48.0 Configuration:
./configure --build=x86_64-redhat-linux-gnu
--host=x86_64-redhat-linux-gnu --program-prefix=
--disable-dependency-tracking --prefix=/usr --exec-prefix=/usr
--bindir=/usr/bin --sbindir=/usr/sbin --sysconfdir=/etc
--datadir=/usr/share --includedir=/usr/include --libdir=/usr/lib64
--libexecdir=/usr/libexec --localstatedir=/var
--sharedstatedir=/var/lib --mandir=/usr/share/man
--infodir=/usr/share/info --with-default-dm-run-dir=/run
--with-default-run-dir=/run/lvm --with-default-pid-dir=/run
--with-default-locking-dir=/run/lock/lvm --with-usrlibdir=/usr/lib64
--enable-fsadm --enable-write_install --with-user= --with-group=
--with-device-uid=0 --with-device-gid=6 --with-device-mode=0660
--enable-pkgconfig --enable-cmdlib --enable-dmeventd
--enable-blkid_wiping --with-udevdir=/usr/lib/udev/rules.d
--enable-udev_sync --with-thin=internal --with-cache=internal
--enable-lvmpolld --enable-lvmlockd-dlm --enable-lvmlockd-dlmcontrol
--enable-lvmlockd-sanlock --enable-dbus-service --enable-notify-dbus
--enable-dmfilemapd --with-writecache=internal --with-vdo=internal
--with-vdo-format=/usr/bin/vdoformat --with-integrity=internal
--with-default-use-devices-file=1 --disable-silent-rules
--enable-app-machineid --enable-editline --disable-readline
```

```
# cat /etc/os-release
NAME="Red Hat Enterprise Linux CoreOS"
ID="rhcos"
ID_LIKE="rhel fedora"
VERSION="416.94.202407231922-0"
VERSION_ID="4.16"
VARIANT="CoreOS"
VARIANT_ID=coreos
PLATFORM_ID="platform:el9"
PRETTY_NAME="Red Hat Enterprise Linux CoreOS 416.94.202407231922-0"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:redhat:enterprise_linux:9::baseos::coreos"
HOME_URL="https://www.redhat.com/"
DOCUMENTATION_URL="https://docs.okd.io/latest/welcome/index.html"
BUG_REPORT_URL="https://access.redhat.com/labs/rhir/"
REDHAT_BUGZILLA_PRODUCT="OpenShift Container Platform"
REDHAT_BUGZILLA_PRODUCT_VERSION="4.16"
REDHAT_SUPPORT_PRODUCT="OpenShift Container Platform"
REDHAT_SUPPORT_PRODUCT_VERSION="4.16"
OPENSHIFT_VERSION="4.16"
RHEL_VERSION=9.4
OSTREE_VERSION="416.94.202407231922-0"
```

Best regards
