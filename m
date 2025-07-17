Received: from mail-oo1-f43.google.com (mail-oo1-f43.google.com [209.85.161.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 517D71F872D
	for <lvm-devel@lists.linux.dev>; Thu, 17 Jul 2025 17:11:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1752772313; cv=none; b=UQ5r7j0ZRXZKbqqM1u1OE0ksZqBq7s1VkGrUps9IZ5EeiJ8+bsPFv8VuH7DnMPYQeqh99JKniuk+YHHJQ6bbVIaQRUgsgxI0GBzfmvbpSpeV7IzSWEGZ9HY5vwUM8GRP/mshRI2YP3OfdRv8x+XDq1PjRV6CUW9RKG/ybAXWpOM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1752772313; c=relaxed/simple;
	bh=4YOGlXRZEoUAp5bH/i+7FGbx5UG9rq6tPRbv3i5Q/6g=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=KXfCxmgKDan80rS+jdVXQUDNMy1TAIQQWFtALCh2z92bw4kQhauF9LtBfckAKxQsbzTRT52StaAtXi8bzx8871uDadDlk//ZKNSOBdldtaz5mkWwacMDFDyD0LON6GZJQ6HJUYnDz7cYMA74884DF9oBMVjlQ5MQJPz6XJt5z+Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com; spf=fail smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=Dk6HFaKb; arc=none smtp.client-ip=209.85.161.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="Dk6HFaKb"
Received: by mail-oo1-f43.google.com with SMTP id 006d021491bc7-61598534619so577247eaf.2
        for <lvm-devel@lists.linux.dev>; Thu, 17 Jul 2025 10:11:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1752772310; x=1753377110; darn=lists.linux.dev;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=2v8O+AEArLO4IByOGO4OXaiIVAGOX5RGYfwJrwGGNHc=;
        b=Dk6HFaKbw4qtJgSc95djnypYwI8T5YUTdawcor5jIKAEHBSvsOJxLJ1OFJjSfr5h0d
         zjpGA7MuVY7HgWIq1cZ9rE8DONFEeg92Ls5kaOUcrSvXSBgmUM+YT/ROXedXUGhMMoIK
         UYCh0cxBbzLXLaMxn5gkojXfcYHOmTkYYPnycHOtny7NWmfxPhXjt8dvwTJPwI9DrizL
         AUVggM8nQ+4eWs1cJ4s8UnmKFcbttC+YD2HDYmK6vqAg/wxw3UpBJdYkZQE384sOMlyp
         n+JvCj7DAtWXABJUL8z6Melw4prNEHDxzytgFzmo/R2f88iQmHGPCqXVsS0eDmlVwlTt
         srCg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1752772310; x=1753377110;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=2v8O+AEArLO4IByOGO4OXaiIVAGOX5RGYfwJrwGGNHc=;
        b=KjR+WJYsXcaKkBu3Fo3Vw2tQeOHk8C5QtPDoFYqjSQxlvv1lnwfHNZnOYz0aR9QkXC
         teBKtuSsqM5WhYIXPZAnFWV4b3l5ox4WqVxoo92cniIC28dSv6A9rT8iP6Ub1StGRGgh
         R1+5d3ECO1qEF3iWYSgELdN/667rjjDBnjZJFbPFuLpdUmtZoldJa4p57pgOt45R2Z2U
         1Vv/n3hJfxPe+4+i2+drdEeHtySzFDNuvjf4nIYE14irhgwF43KT7tCvwd8qUHXGn5zt
         QcxkymPidiAwBX+dBuhUEJCswCPOUSnRJpoH448Ps29dn+f0RjvyATG9vn6dQ9zobsl8
         JUBw==
X-Gm-Message-State: AOJu0YwU4QYEzfQMI13eOspl8mQfHwygSq11tdRins+9Ky3O1mBcUk4o
	M73PTp75nvT78wHs5y7/nvrUd16UYmEdeQp/7JXigzVmS9WDDnlC/7FEY+xO7E8FKGF7Oi6MEK1
	kYGTOx+DdzPTJDrUzUa31YzmbN9dgs1uF+PGjEp8pJI1qGvxvoRtSa2S6/g==
X-Gm-Gg: ASbGncv4n3+V41SSyXvdHc1IHAiFePIVUMTjNgSVH88WJ2UgZSR8tt4dTVk8u62Biwj
	Pw/nV4aRda9imh0jInAfLc2ZHy6p2eSXDvOkO6HM3s3fWcCgGCpLvSMBx3/SJ8pUwNF42EW6o5D
	mxp79dliMkAskHkhxwbxymv4uS5I9RHDy23utRnSowxmv1VocoZaoSgwHXh9ulkk9TPzoUhHKoy
	1bqRjCg
X-Google-Smtp-Source: AGHT+IHYtrBTX5mpTJlOKkBLrxqcjBX0B/YpqJ142RkzPZE1icl2S7nGQhdhKOkskG6dA5ZpuXSJ61//bKcQ2zpUfH8=
X-Received: by 2002:a05:6820:c087:b0:615:ac59:7613 with SMTP id
 006d021491bc7-615ac59804amr2294380eaf.5.1752772309685; Thu, 17 Jul 2025
 10:11:49 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Divyam Goel <dgoel@purestorage.com>
Date: Thu, 17 Jul 2025 10:11:38 -0700
X-Gm-Features: Ac12FXxfnkThjwo54lnsrTDdS_GW83_8IkLgz2s3MS9MbmJO6yAd3ygATwTHgmE
Message-ID: <CACefT4cQ7cAf+iqLUjxCn7aC7Xn+WwNNbHdXrBZ3mouSEcNCeQ@mail.gmail.com>
Subject: Understand limitations of lvremove snapshot
To: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Team,
Good day!

I have a setup using lvm thin pool with thin snapshots for the logical
volumes. I noticed that when I delete these snapshots there is a IO
pause during the time lvremove command holds the critical section
lock. This IO pause seems to be pretty significant in the order of 20
seconds on my high-performance NVMe setup. I have appended all the
debug information below.

My questions are:
- Is this IO pause always expected?
- What factors influence the duration of this pause and how can we
mitigate it or completely avoid it?

Thank you very much for all your help.

Best,
Divyam

### Debug information is as follows

## LVM version
```
root@init500-d4:/# lvm version
  LVM version:     2.02.176(2) (2017-11-03)
  Library version: 1.02.145 (2017-11-03)
  Driver version:  4.42.0
  Configuration:   ./configure --build=3Dx86_64-linux-gnu --prefix=3D/usr
--includedir=3D${prefix}/include --mandir=3D${prefix}/share/man
--infodir=3D${prefix}/share/info --sysconfdir=3D/etc --localstatedir=3D/var
--disable-silent-rules --libdir=3D${prefix}/lib/x86_64-linux-gnu
--libexecdir=3D${prefix}/lib/x86_64-linux-gnu --runstatedir=3D/run
--disable-maintainer-mode --disable-dependency-tracking --exec-prefix=3D
--bindir=3D/bin --libdir=3D/lib/x86_64-linux-gnu --sbindir=3D/sbin
--with-usrlibdir=3D/usr/lib/x86_64-linux-gnu --with-optimisation=3D-O2
--with-cache=3Dinternal --with-clvmd=3Dcorosync --with-cluster=3Dinternal
--with-device-uid=3D0 --with-device-gid=3D6 --with-device-mode=3D0660
--with-default-pid-dir=3D/run --with-default-run-dir=3D/run/lvm
--with-default-locking-dir=3D/run/lock/lvm --with-thin=3Dinternal
--with-thin-check=3D/usr/sbin/thin_check
--with-thin-dump=3D/usr/sbin/thin_dump
--with-thin-repair=3D/usr/sbin/thin_repair --enable-applib
--enable-blkid_wiping --enable-cmdlib --enable-cmirrord
--enable-dmeventd --enable-dbus-service --enable-lvmetad
--enable-lvmlockd-dlm --enable-lvmlockd-sanlock --enable-lvmpolld
--enable-notify-dbus --enable-pkgconfig --enable-readline
--enable-udev_rules --enable-udev_sync
```

## Before deleting the snapshot
```
root@init500-d3-10.9.1.86:~# date && fio --blocksize=3D2M
--ioengine=3Dlibaio --readwrite=3Dwrite --numjobs=3D1 --direct=3D1 --iodept=
h=3D1
--end_fsync=3D1 --name=3Dfiowrite
--filename=3D/dev/mapper/pwx0-57414833981247139 --runtime=3D2m
--time_based=3D1
Thu Jul 17 01:08:03 UTC 2025
fiowrite: (g=3D0): rw=3Dwrite, bs=3D(R) 2048KiB-2048KiB, (W)
2048KiB-2048KiB, (T) 2048KiB-2048KiB, ioengine=3Dlibaio, iodepth=3D1
fio-3.7
Starting 1 process
Jobs: 1 (f=3D1): [W(1)][100.0%][r=3D0KiB/s,w=3D1998MiB/s][r=3D0,w=3D998 IOP=
S][eta 00m:00s]
fiowrite: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D68396: Thu Jul 17 01:10:=
03 2025
  write: IOPS=3D1824, BW=3D3649MiB/s (3826MB/s)(428GiB/120001msec)
    slat (usec): min=3D77, max=3D15965, avg=3D247.70, stdev=3D87.94
    clat (nsec): min=3D994, max=3D9362.8k, avg=3D299209.74, stdev=3D180516.=
14
     lat (usec): min=3D275, max=3D25329, avg=3D547.07, stdev=3D197.48
    clat percentiles (usec):
     |  1.00th=3D[  109],  5.00th=3D[  133], 10.00th=3D[  149], 20.00th=3D[=
  180],
     | 30.00th=3D[  212], 40.00th=3D[  235], 50.00th=3D[  255], 60.00th=3D[=
  269],
     | 70.00th=3D[  277], 80.00th=3D[  379], 90.00th=3D[  578], 95.00th=3D[=
  685],
     | 99.00th=3D[  848], 99.50th=3D[  955], 99.90th=3D[ 1516], 99.95th=3D[=
 2073],
     | 99.99th=3D[ 2933]
   bw (  MiB/s): min=3D 1796, max=3D 5044, per=3D100.00%, avg=3D3655.49,
stdev=3D642.72, samples=3D239
   iops        : min=3D  898, max=3D 2522, avg=3D1827.69, stdev=3D321.38, s=
amples=3D239
  lat (nsec)   : 1000=3D0.01%
  lat (usec)   : 4=3D0.01%, 20=3D0.01%, 50=3D0.01%, 100=3D0.47%, 250=3D46.5=
8%
  lat (usec)   : 500=3D39.43%, 750=3D10.89%, 1000=3D2.22%
  lat (msec)   : 2=3D0.35%, 4=3D0.05%, 10=3D0.01%
  cpu          : usr=3D8.23%, sys=3D38.62%, ctx=3D219645, majf=3D0, minf=3D=
7292
  IO depths    : 1=3D100.0%, 2=3D0.0%, 4=3D0.0%, 8=3D0.0%, 16=3D0.0%, 32=3D=
0.0%, >=3D64=3D0.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     issued rwts: total=3D0,218931,0,1 short=3D0,0,0,0 dropped=3D0,0,0,0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D1

Run status group 0 (all jobs):
  WRITE: bw=3D3649MiB/s (3826MB/s), 3649MiB/s-3649MiB/s
(3826MB/s-3826MB/s), io=3D428GiB (459GB), run=3D120001-120001msec
```

## While the snapshot deletion was in progress
```
root@init500-d3-10.9.1.86:~# date && fio --blocksize=3D2M
--ioengine=3Dlibaio --readwrite=3Dwrite --numjobs=3D1 --direct=3D1 --iodept=
h=3D1
--end_fsync=3D1 --name=3Dfiowrite
--filename=3D/dev/mapper/pwx0-57414833981247139 --runtime=3D2m
--time_based=3D1
Thu Jul 17 01:12:16 UTC 2025
fiowrite: (g=3D0): rw=3Dwrite, bs=3D(R) 2048KiB-2048KiB, (W)
2048KiB-2048KiB, (T) 2048KiB-2048KiB, ioengine=3Dlibaio, iodepth=3D1
fio-3.7
Starting 1 process
Jobs: 1 (f=3D1): [W(1)][100.0%][r=3D0KiB/s,w=3D2182MiB/s][r=3D0,w=3D1091
IOPS][eta 00m:00s]
fiowrite: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D71680: Thu Jul 17 01:14:=
17 2025
  write: IOPS=3D1846, BW=3D3693MiB/s (3872MB/s)(433GiB/120002msec)
    slat (usec): min=3D140, max=3D21376k, avg=3D318.43, stdev=3D45413.12
    clat (usec): min=3D26, max=3D3981, avg=3D222.19, stdev=3D72.46
     lat (usec): min=3D264, max=3D21376k, avg=3D540.77, stdev=3D45412.87
    clat percentiles (usec):
     |  1.00th=3D[  103],  5.00th=3D[  127], 10.00th=3D[  143], 20.00th=3D[=
  167],
     | 30.00th=3D[  192], 40.00th=3D[  215], 50.00th=3D[  229], 60.00th=3D[=
  247],
     | 70.00th=3D[  262], 80.00th=3D[  269], 90.00th=3D[  273], 95.00th=3D[=
  277],
     | 99.00th=3D[  363], 99.50th=3D[  498], 99.90th=3D[ 1012], 99.95th=3D[=
 1303],
     | 99.99th=3D[ 1926]
   bw (  MiB/s): min=3D 1840, max=3D 5484, per=3D100.00%, avg=3D4486.12,
stdev=3D598.22, samples=3D197
   iops        : min=3D  920, max=3D 2742, avg=3D2243.03, stdev=3D299.11, s=
amples=3D197
  lat (usec)   : 50=3D0.01%, 100=3D0.81%, 250=3D60.87%, 500=3D37.82%, 750=
=3D0.27%
  lat (usec)   : 1000=3D0.12%
  lat (msec)   : 2=3D0.10%, 4=3D0.01%
  cpu          : usr=3D7.83%, sys=3D34.36%, ctx=3D221768, majf=3D0, minf=3D=
22
  IO depths    : 1=3D100.0%, 2=3D0.0%, 4=3D0.0%, 8=3D0.0%, 16=3D0.0%, 32=3D=
0.0%, >=3D64=3D0.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     issued rwts: total=3D0,221554,0,1 short=3D0,0,0,0 dropped=3D0,0,0,0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D1

Run status group 0 (all jobs):
  WRITE: bw=3D3693MiB/s (3872MB/s), 3693MiB/s-3693MiB/s
(3872MB/s-3872MB/s), io=3D433GiB (465GB), run=3D120002-120002msec
```

## Snapshot delete in progress
```
root@init500-d3-10.9.1.86:~# date && lvm lvremove -vvvv -dddddd
--noudevsync -y pwx0/672921901357301927
Thu Jul 17 01:12:37 UTC 2025
#lvmcmdline.c:2831          Parsing: lvremove -vvvv -dddddd
--noudevsync -y pwx0/672921901357301927
...
#lvmcmdline.c:3050          Completed: lvremove -vvvv -dddddd
--noudevsync -y pwx0/672921901357301927
```

## From above we can see max latency is 25 ms when no snapshot delete
is running and 21 sec when snapshot delete is in progress.

### More debug information is as follows

```
root@init500-d3-10.9.1.86:~# lsblk
NAME                            MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
nvme0n1                         259:8    0  1.5T  0 disk
=E2=94=9C=E2=94=80nvme0n1p3                     259:12   0  1.5T  0 part
=E2=94=82 =E2=94=9C=E2=94=80vgroot-lvswap01             253:1    0    4G  0=
 lvm
=E2=94=82 =E2=94=94=E2=94=80vgroot-lvroot               253:0    0  1.5T  0=
 lvm   /
=E2=94=9C=E2=94=80nvme0n1p1                     259:10   0    1G  0 part  /=
boot/efi
=E2=94=94=E2=94=80nvme0n1p2                     259:11   0  500M  0 part  /=
boot
nvme3n1                         259:9    0  1.5T  0 disk
=E2=94=94=E2=94=80md127                           9:127  0  5.8T  0 raid0
  =E2=94=9C=E2=94=80pwx0-pxpool_tmeta           253:2    0   15G  0 lvm
  =E2=94=82 =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0=
 lvm
  =E2=94=82   =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0=
 lvm
  =E2=94=94=E2=94=80pwx0-pxpool_tdata           253:3    0  5.8T  0 lvm
    =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0 lvm
      =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0 lvm
      =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0 lvm
      =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0 lvm
nvme6n1                         259:7    0  1.5T  0 disk
nvme9n1                         259:5    0  1.5T  0 disk
nvme2n1                         259:1    0  1.5T  0 disk
=E2=94=94=E2=94=80md127                           9:127  0  5.8T  0 raid0
  =E2=94=9C=E2=94=80pwx0-pxpool_tmeta           253:2    0   15G  0 lvm
  =E2=94=82 =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0=
 lvm
  =E2=94=82   =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0=
 lvm
  =E2=94=94=E2=94=80pwx0-pxpool_tdata           253:3    0  5.8T  0 lvm
    =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0 lvm
      =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0 lvm
      =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0 lvm
      =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0 lvm
pxd!pxd729796226867285023       252:2    0    1G  0 disk
/var/lib/osd/mounts/1gb-d3
nvme5n1                         259:3    0  1.5T  0 disk
nvme8n1                         259:4    0  1.5T  0 disk
pxd!pxd57414833981247139        252:1    0    3T  0 disk
/var/lib/osd/mounts/3tb-d3
nvme1n1                         259:0    0  1.5T  0 disk
=E2=94=94=E2=94=80md127                           9:127  0  5.8T  0 raid0
  =E2=94=9C=E2=94=80pwx0-pxpool_tmeta           253:2    0   15G  0 lvm
  =E2=94=82 =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0=
 lvm
  =E2=94=82   =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0=
 lvm
  =E2=94=94=E2=94=80pwx0-pxpool_tdata           253:3    0  5.8T  0 lvm
    =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0 lvm
      =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0 lvm
      =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0 lvm
      =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0 lvm
nvme4n1                         259:2    0  1.5T  0 disk
=E2=94=94=E2=94=80md127                           9:127  0  5.8T  0 raid0
  =E2=94=9C=E2=94=80pwx0-pxpool_tmeta           253:2    0   15G  0 lvm
  =E2=94=82 =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0=
 lvm
  =E2=94=82   =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0=
 lvm
  =E2=94=82   =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0=
 lvm
  =E2=94=94=E2=94=80pwx0-pxpool_tdata           253:3    0  5.8T  0 lvm
    =E2=94=94=E2=94=80pwx0-pxpool-tpool         253:4    0  5.8T  0 lvm
      =E2=94=9C=E2=94=80pwx0-248435070782584467 253:10   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-729796226867285023 253:8    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-681871867032118384 253:17   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-pxMetaFS           253:6    0   64G  0 lvm
      =E2=94=9C=E2=94=80pwx0-6467409125236334   253:15   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-353177431893931550 253:13   0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-369272389739017953 253:9    0    1G  0 lvm
      =E2=94=9C=E2=94=80pwx0-294122483306511515 253:18   0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-57414833981247139  253:7    0    3T  0 lvm
      =E2=94=9C=E2=94=80pwx0-393368701089705163 253:16   0    3T  0 lvm
      =E2=94=94=E2=94=80pwx0-pxpool             253:5    0  5.8T  0 lvm
nvme7n1                         259:6    0  1.5T  0 disk

root@init500-d3-10.9.1.86:~# mdadm -D /dev/md127
/dev/md127:
           Version : 1.2
     Creation Time : Fri Jul 11 20:17:18 2025
        Raid Level : raid0
        Array Size : 6250725376 (5.82 TiB 6.40 TB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Fri Jul 11 20:17:18 2025
             State : clean
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

        Chunk Size : 1024K

Consistency Policy : none

              Name : any:pwx0
              UUID : f6ae3624:0d629903:d13686a9:146fc8cf
            Events : 0

    Number   Major   Minor   RaidDevice State
       0     259        1        0      active sync   /dev/nvme2n1
       1     259        9        1      active sync   /dev/nvme3n1
       2     259        2        2      active sync   /dev/nvme4n1
       3     259        0        3      active sync   /dev/nvme1n1

root@init500-d3-10.9.1.86:~# lvs
  LV                 VG     Attr       LSize  Pool   Origin
 Data%  Meta%  Move Log Cpy%Sync Convert
  248435070782584467 pwx0   Vwi-a-t--- <2.93t pxpool 57414833981247139  99.=
93
  294122483306511515 pwx0   Vwi-a-t--- <2.93t pxpool 57414833981247139  99.=
93
  353177431893931550 pwx0   Vwi-a-t---  1.00g pxpool 729796226867285023 4.7=
8
  369272389739017953 pwx0   Vwi-a-t---  1.00g pxpool 729796226867285023 4.7=
8
  393368701089705163 pwx0   Vwi-a-t--- <2.93t pxpool 57414833981247139  99.=
93
  57414833981247139  pwx0   Vwi-a-t--- <2.93t pxpool                    99.=
93
  6467409125236334   pwx0   Vwi-a-t---  1.00g pxpool 729796226867285023 4.7=
8
  672921901357301927 pwx0   Vwi-a-t--- <2.93t pxpool 57414833981247139  99.=
93
  681871867032118384 pwx0   Vwi-a-t---  1.00g pxpool 729796226867285023 4.7=
8
  729796226867285023 pwx0   Vwi-a-t---  1.00g pxpool                    4.7=
8
  84211885115688699  pwx0   Vwi-a-t--- <2.93t pxpool 57414833981247139  99.=
93
  pxMetaFS           pwx0   Vwi-a-t--- 64.00g pxpool                    0.0=
5
  pxpool             pwx0   twi-aot--- <5.78t
 89.58  17.56
  pxreserve          pwx0   -wi------k 15.00g
  lvroot             vgroot -wi-ao----  1.45t
  lvswap01           vgroot -wi-a-----  4.00g

root@init500-d3-10.9.1.86:~# vgs
  VG     #PV #LV #SN Attr   VSize VFree
  pwx0     1  14   0 wz--n- 5.82t    0
  vgroot   1   2   0 wz--n- 1.45t    0

root@init500-d3-10.9.1.86:~# pvs
  PV             VG     Fmt  Attr PSize PFree
  /dev/md127     pwx0   lvm2 a--  5.82t    0
  /dev/nvme0n1p3 vgroot lvm2 a--  1.45t    0

root@init500-d3-10.9.1.86:~# lvdisplay pwx0/57414833981247139
  --- Logical volume ---
  LV Path                /dev/pwx0/57414833981247139
  LV Name                57414833981247139
  VG Name                pwx0
  LV UUID                d12Vj9-J51S-Vsis-rt4X-G53n-n7wd-bzWyio
  LV Write Access        read/write
  LV Creation host, time init500-d3, 2025-07-11 20:22:56 +0000
  LV Pool name           pxpool
  LV Status              available
  # open                 2
  LV Size                <2.93 TiB
  Mapped size            99.93%
  Current LE             768000
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     16384
  Block device           253:7

root@init500-d3-10.9.1.86:~# lvdisplay pwx0/672921901357301927
  --- Logical volume ---
  LV Path                /dev/pwx0/672921901357301927
  LV Name                672921901357301927
  VG Name                pwx0
  LV UUID                vuZ9j9-lhN9-FGxe-qCVp-Tchf-zJsd-gvhJNt
  LV Write Access        read/write
  LV Creation host, time init500-d3, 2025-07-16 22:51:10 +0000
  LV Pool name           pxpool
  LV Thin origin name    57414833981247139
  LV Status              available
  # open                 2
  LV Size                <2.93 TiB
  Mapped size            99.93%
  Current LE             768000
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     16384
  Block device           253:14
```
