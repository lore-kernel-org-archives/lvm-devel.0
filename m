Received: from mail-pf1-f182.google.com (mail-pf1-f182.google.com [209.85.210.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5850E1799D
	for <lvm-devel@lists.linux.dev>; Sun,  8 Sep 2024 01:37:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1725759465; cv=none; b=qrkCX6jV1L4u2RUxQ9GcDjOe737gnf7vNNpyZ7XBWKMODOwrXZtldGLRepk1bnUAafJ/K/HvA6tczLQEaF59n6stoeyi5gy5MJuQHFxksrbrZiaBjcGgZvdBtXn/3Cqd77sTfeb42LyK/P09ZK8IDZ7u/n+vGtcF3m5oasG6KD0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1725759465; c=relaxed/simple;
	bh=D0J4pha/A+Sms255MV7Fd8Qx5cJAlsDepxc5GJ87rtE=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=sbtC9wgXcRbWbAw8aUP7cIncOMVVQZxBSRpp5Rdd6C2F3/g9yPcF5uRCteObhn1iKuXiJ0G/xAbRpJNeZJFojkK+3ZIYq+8NorqBLlizIHtkv//F4ath4cOrSOoMVCG1YHycLhRJNmcXT1FXH/RmMBIdOJMtH1//wF0zHUFXbFM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Y+Qq+1ZK; arc=none smtp.client-ip=209.85.210.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y+Qq+1ZK"
Received: by mail-pf1-f182.google.com with SMTP id d2e1a72fcca58-718d704704aso1723355b3a.3
        for <lvm-devel@lists.linux.dev>; Sat, 07 Sep 2024 18:37:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1725759463; x=1726364263; darn=lists.linux.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=b488v9xgriubCUN8lfdc0HHMPN/3dTIGCt8jW/2a0fg=;
        b=Y+Qq+1ZKEUgBqroEby7cjmRN1bts2jIfiAaKTSNs/reBhtzE4gN1CWRccMMiw5SvRV
         Bte8Xd6WEZ/wsdXLgVDXFvq14x0PNZ8TVsbEfipoCzV4JPLR6fILVtTD2abh2WilZx+H
         vsTncNUSxlmJOEmsqdt2zKuBLgYeLSOXlQ98an0AgEZ1PAGl+jlEWzNYRQUy2DgHlZjk
         /6Pq5rRsoObavmozwYL2TiRWgjOwAioNIvepNU7TYNgfpvHRLsTqPiiamttNBGniZkbw
         NR0gVP4ycrIBAVf9rHrJWxkTDWg7jMpcgjYI1jQ3Y+HbBGqR2vZi1+N+k1GdlpCjtN9i
         BDWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1725759463; x=1726364263;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=b488v9xgriubCUN8lfdc0HHMPN/3dTIGCt8jW/2a0fg=;
        b=M9A+on5GW+LpseUXeQzof81d1EQ9Ukf+QxVmIkz2BRq/lf6Y6OGRkuY2jzloKRfhpX
         feYiRxiznZFhncVWvbCoNMnaR/v8U/Ru4yGApy+xGrazYQMXp+2z43IMxuI8rKp93q4k
         IfqjxDRh8nAlAaqoOhkdJOdfGhEC039k/0nqHWje8GhLMudOFL52JWJSOOF24qH6q3TY
         HfKm2o1ipISw94Jiq/qKVukGH/qidIV5JJUaO/wcJgPUmL0xZbkhz8yS5Y7ifN9wVXS/
         2xZnkRE8jWP1VkXW5BYDXj9UACi/okEUxHfaOIQJJSxe3Mu7q3RCGbirJ/ySif84ePTW
         YfsQ==
X-Gm-Message-State: AOJu0YyPK6Fl9R53ibFhIKHCi909QmItWkj6bJbeA1JwYnhggu0gQg+d
	8VRJEVZTlQvPZK8jKvnLUD5pQOgexbdTdZi0uIxtE6nSe9vmeu/7wpA8EGiyevmp1YTHtcjyU82
	B5KeqFD5/1NLYX7mHHE4z28Y3LdpyNuwdK78=
X-Google-Smtp-Source: AGHT+IGidI6tIMKzAGl0/JFeT/mcAerHT9QntDX+eG5heeNNQgyWNGF/K32ESzm74pexmuh+DOroWRRjIAMMXQ24OEs=
X-Received: by 2002:a05:6a21:3510:b0:1be:c4bb:6f31 with SMTP id
 adf61e73a8af0-1cf2a0a2f2dmr4413087637.18.1725759463167; Sat, 07 Sep 2024
 18:37:43 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Date: Sun, 8 Sep 2024 07:07:32 +0530
Message-ID: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
Subject: thin pool powerfail tests and data loss
To: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Team,
Greetings!

In my experiments with thin pool and power cycle tests, I find that
the inflight data has not been persisted, even if there is a sync
following write that got completed.

suppose we have the following bdev stackup:
bdevs(multi) -> mpath -> lvm pv -> lvm vg -> lvm thin pool -> multiple
thin vols.

Each of the thin vols that has inflight data, has a corresponding sync
checkpoint periodically. The expectation is all writes before the sync
are persisted to disk and can survive power reset tests.

Like below seq on many thin vols on the thin pool.
write -> write -> write -> fsync(fd) -> write -> write -> fsync(fd) -> ..etc

Now my code only does a fsync(fd) on the thin volume (block device directly).
There are no fs mounts on the volume.
Is this sufficient or should the thin pool (/dev/mapper/pool) also be
synced along?
What would be the proper sequence of sync actions to survive a power reset?

I am also trying to validate if this is an issue because mpath is
involved in any way(another dm layer in between), but would appreciate
some guidance in this
regard.

## setup versions ##
```
# lvm version
  LVM version:     2.03.07(2) (2019-11-30)
  Library version: 1.02.167 (2019-11-30)
  Driver version:  4.41.0
  Configuration:   ./configure --build=x86_64-linux-gnu --prefix=/usr
--includedir=${prefix}/include --mandir=${prefix}/share/man
--infodir=${prefix}/share/info --sysconfdir=/etc --localstatedir=/var
--disable-silent-rules --libdir=${prefix}/lib/x86_64-linux-gnu
--libexecdir=${prefix}/lib/x86_64-linux-gnu --runstatedir=/run
--disable-maintainer-mode --disable-dependency-tracking --exec-prefix=
--bindir=/bin --libdir=/lib/x86_64-linux-gnu --sbindir=/sbin
--with-usrlibdir=/usr/lib/x86_64-linux-gnu --with-optimisation=-O2
--with-cache=internal --with-device-uid=0 --with-device-gid=6
--with-device-mode=0660 --with-default-pid-dir=/run
--with-default-run-dir=/run/lvm
--with-default-locking-dir=/run/lock/lvm --with-thin=internal
--with-thin-check=/usr/sbin/thin_check
--with-thin-dump=/usr/sbin/thin_dump
--with-thin-repair=/usr/sbin/thin_repair --enable-applib
--enable-blkid_wiping --enable-cmdlib --enable-dmeventd
--enable-dbus-service --enable-lvmlockd-dlm --enable-lvmlockd-sanlock
--enable-lvmpolld --enable-notify-dbus --enable-pkgconfig
--enable-readline --enable-udev_rules --enable-udev_sync
# cat /etc/os-release
NAME="Ubuntu"
VERSION="20.04.2 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.2 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
#
```

Best regards
LN
