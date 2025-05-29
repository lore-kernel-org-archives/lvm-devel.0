Received: from mail-pg1-f180.google.com (mail-pg1-f180.google.com [209.85.215.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 559C41F0E56
	for <lvm-devel@lists.linux.dev>; Thu, 29 May 2025 17:06:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748538384; cv=none; b=eMNRck0EbSbExLUjOwB1hX173tBq80ZxibSA1G1sSEQIfe5ezWSlmtBOADp7Q+a2xcaDz3FBNW+fOKpg/YkgcvPpLffwHoou2K6BUf9zGIFlQckqNjkrJxSxJXRm+fDgMbRAPxRdJBSMeFMDzM6VGKu6mffwF5iPyw1bz1SFViY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748538384; c=relaxed/simple;
	bh=nY9J4mMc7qOQS9ppBSmVkjOYhWE111XhB4Ve2O4cRTc=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=MrgH64a4GMsuxusAlfPBG6uydmVl6g81dfatP9LaCtlt+KCa99opvB4w9SU3MTVw/THxrk6n0aduaPaiTM92R1qGM0dFv7e7A2iwiVzGcAaQroTWZIeN9uFM+fx1EQg0voIt+XFHjg9n1ZsrLZyowwAVoPKQAxOaLe7G0NItaAI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Uacg8pmS; arc=none smtp.client-ip=209.85.215.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Uacg8pmS"
Received: by mail-pg1-f180.google.com with SMTP id 41be03b00d2f7-b2c3c689d20so902554a12.3
        for <lvm-devel@lists.linux.dev>; Thu, 29 May 2025 10:06:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1748538382; x=1749143182; darn=lists.linux.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=PgYnkQ3RqIVioqv7I2zPbuNAlEZPazbPe8zcXhfqo2o=;
        b=Uacg8pmSzTOWZ83RaQP9h1UdrSsMblrdKkicZWMzpWTlsA87KLBnS8Nq+5iYfr1qo5
         tn2updf+lrZcjpI25WaL+P5K+yxxOSBLYD6cVpmGkX5FO8bYhQW7gx5qF+3Iwz+P2TyS
         TxNUWnhfMyD1PW6msPrJRj+fVXE9GFaCabiXrjzOrX3eJQMXA7+1/fVeTqpE49JUChFv
         1kdydeRudFdSQOQbAObTp1HAgxnlFcWaA1qi4AaWa33vV9gd+IYWyfQ/GIvw/1j60ir7
         RV528MvfyTbpPl1O1puImTsPNI5ZmpsHQ7K7E9yNAEWAC3odn/rxKkX5RLykm0bXFz+J
         HODw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1748538382; x=1749143182;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=PgYnkQ3RqIVioqv7I2zPbuNAlEZPazbPe8zcXhfqo2o=;
        b=hgEbSGGZViZuOftyVdP6599A60Fwkl2NG/UK4XAPf91+PHGlDpFMDnca21qLS8XY2C
         3SOpbmvQJqOhIDadTYjC5/mpQqthMRyvOb1eMP7Qq13Aq+HCb6Vrv4InQjSJi+LV7t7T
         m3qA3Mlp6D8E5XprGYtymhwxUcO10Na0CxphiSCqo5WLITa3ttwrgxW2kkGz3JLn8Kka
         a2XycWHIXutn6+5CIo+tMScgFZ3X5RqLwFTzfTzt3uVXcUTs96/KMuqF1zilb8/BMh7P
         I2iv6X+pH0zlrft+2mcPQJf5Q0TQcUXHk9Jl1Z2URw06ufLWm+jFlrhS0wpw2bUMnYBW
         Nmmg==
X-Gm-Message-State: AOJu0Yw/tOjn7hVBGvoGl2WObAsnL5qiAP2hrjU7U0Vh36pEJIakhP3H
	zenX6o9RnTWcHjZ81UHUJEcSMrfhsgBqparhhKVZPC2vifo+l3/cELpAu9MQb6QAdJzBxVKjYKm
	wwd4fBoQrJ1j7WwIuUeOE3lWf6GhlbV/5KR3Y
X-Gm-Gg: ASbGnctZMHJbYsxSk55WOAN2wNWZmmrLOytfDZZebf9LVa1tfUqWXOFC8wAxY99g7hV
	huYW9xUZCekTVZQc53+fM7La66cFGPxxFvYNpWEWlDvbmoUaTz76oGJF5HT4zt5N0NdLy3Dkp+y
	qiUZy46ntQJX6C283flcw2/lksML0gqlBURA==
X-Google-Smtp-Source: AGHT+IE6LAGNeUEXAoBU+zjQkegGcm5vEGb8beCItzU8MdhRPfXWEkXY8yXX0eDQDfIzRy/6JrW+grrYe2WaRfMJALU=
X-Received: by 2002:a17:90b:4cc5:b0:311:fc8b:31b5 with SMTP id
 98e67ed59e1d1-312415336b6mr598318a91.14.1748538381941; Thu, 29 May 2025
 10:06:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Date: Thu, 29 May 2025 22:36:07 +0530
X-Gm-Features: AX0GCFufH9F62_6f5B4ueaXv0JA-DXNqcRsydkEKkNA2D_jLODr9hCNy2QbEX7I
Message-ID: <CAHJKXw3v-UUwg1sAvYThJMZHi5GBvqvHpaDVSYaVcLGTe048Lg@mail.gmail.com>
Subject: Reg LVM PE Size and any limitations out of it
To: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Team,
A very good day to you.

During vgcreation there exists a field '-s|--physicalextentsize'.
From the man pages it calls out as extent size of PVs in VG.
As a reference on a vg already created, I see that it is called out as
4MiB. [see below]

My questions are as follows:
1) Is this dynamically computed based on the installed PV during VG creation?
Given this cannot be changed after VG creation, what would happen if
the pool were to grow or even the disks were to grow (think san
volumes). would vg limit itself to some capacity limitations above
which it cannot grow, leading to my second follow up question.
2) Is there any limit to the max number of PE in a VG?
It is not called out in any man pages, but an internet search gave me
a max of 16M extents in a VG. So here I am asking for clarification,
and worried if there is such a limit, would it limit then the VG
capacity expansion to only 16M * 4M ~ 64 T [It did not though, I
experimentally validated it].
3) under what scenarios does one need to consider applying
physicalextentsize explicitly?
I am trying to understand the usecase this came about.

Many thanks for your help.
Regards
LN
```
:/# lvm vgdisplay pwx0
  --- Volume group ---
  VG Name               pwx0
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  100
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               1
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               99.93 GiB
  PE Size               4.00 MiB  <<<<< This one
  Total PE              25583
  Alloc PE / Size       25583 / 99.93 GiB
  Free  PE / Size       0 / 0
  VG UUID               Fqmp94-5X9b-O3Xp-JdFh-HSXu-ed8M-YFgflT

:/#
```
