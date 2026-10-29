Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793282068;
	b=qlgf4inrJQGconpzIttwjl/z0JzNvGjwZ3AUG4OCt3N4dFuX8BEu7owlUaYbp3YrZ1x/
	 ko80aCRac4LKwUE3GBJOTCO2XtA5bX78RsCXW1GV9rw6tQRHrEUN30QmgoD2pyGgGBDkQ
	 ZRBb3eCEq5RV9o4i9iLnBOlyKXZK15Yc5TjaPwaQvO/TyWbKSdlgaCGxCbZvv/wnBiNrr
	 c0lznfZBEjCkBKUruV0MmG6NQ3kmUx3hVVv0bWaliiEdap9iH82Rlb1A7kSHhMQRwqF7P
	 hM+9ve1Yj4vR7seYXVWF4bADvrNOgELEycCB4AIE67p7QlPCYCwzRLCUGEMeBsZXbBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793282068;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=LwV4PHfJtcp4jfAzKwMllrgZ7DDC4Dr6DDRyG0hJOyU=;
	b=IAVApriZmwCWEM3QjDrfntzNcmeDtZ1SD9r6hC8lXCAS50m18WvhLZT4w/uUeYfu5Qta
	 UqGVwKKFNCQqDMLrvzqHtGm4QyzMxtpYYlHaEk3koQ2e8S5v2xumLeKP8WEdfUnBZ6zLO
	 PiiSi62Gzg5Qc91V1xRWGd3hUKzhC6KCokqLdiaPRXf4CmYC6KFdJe3V1msDNEiGiVnXR
	 m7MpyjS+eHf239LVU0BdGd+ym+LJRQ4jphaO3eeaXhSahHgw8nWnoh6VlEo50CGUddjVc
	 5A0GqJeSkVRgUVOAUlEgQdhJ7m+srLpnJaYF04wNbtiKJqyz0NsXzZHdWe9Y2mhXRcQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=YAKmfaan;
	arc=none smtp.remote-ip=209.85.221.50
Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2193E606A31A
	for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 13:54:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2193E606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=YAKmfaan
Received: by mail-wr1-f50.google.com with SMTP id ffacd0b85a97d-48bbb06f29bso228335f8f.3
        for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 06:54:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793282066; x=1793886866; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=LwV4PHfJtcp4jfAzKwMllrgZ7DDC4Dr6DDRyG0hJOyU=;
        b=YAKmfaan4gXZ65lehlSg0asYt1UZ4KZWpTObJ2lAiXB1mmbvE/3aDLW/4M6YIEMEII
         bIAbfCddkkUCnkhwMZ9y1Z4D1M1exkgjKxr3uAuIZJ3uTqI42LuiI6ySTaWj9eWB+bWP
         6VkgB4Gkx6/BCbaH7fz+Bcn2qaOJ65BLpfl41rYb3B9x/8UBSc+Br3He+H5liQehyqAT
         asTKUrh3+M56f3qtlQicyYD9h2MuT0kIBkh+eqW8D5slyUhgrLW2fztvyRCO9aX51Kzl
         bp+WPlKb4uybHGvkI50MHyY+Y41BXxpVNLfAUCArM0S86qdoCfPGpDHrwq/MGhticxTl
         NHfw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793282066; x=1793886866;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=LwV4PHfJtcp4jfAzKwMllrgZ7DDC4Dr6DDRyG0hJOyU=;
        b=K2Wh8TekP45xXSCCIjdNV4aS5fOAHSshFuDxogLhburT7yrWkXiWPS9PR9/jYiISZ5
         RWnEsJ09hRqwcnQTurjubH7sEfSUb98OKkeuojNtModNcZnGrfaHrusEpG2AYtfdgLkI
         YH+4hBoW667+s0Mba8MNE3n3bWhLk4EkVTb5Z3OIkSazG3bEiwaK7md5wL++dEZmxOZh
         8NE2hPEyDMWNXdU/i5gOkwd3hLkXOYr/wzl5JsvsaSdFFSvWcXBln7ckgtrc0lBMfvCq
         j/lfdunU8HBRrhXKoIhHCIYNJsT5QxblmJN80qhPcLD9dpUL/oOskjvwL8S0zUmvEU5g
         3ibQ==
X-Gm-Message-State: AFq9FYIiJtjwncw/JbW51rCNbXtiRaswo8Ao5NpddjcsLrFNsoU5InmG
	T0Z0S/fUkdEUtV+XqXqnO6cgktTQXi6hYBabYMIwjX6fc1PGJOPDLLaqmDVwFg==
X-Gm-Gg: AYBFou16vzZQvgdZXu9Xu5jhDdCKIzLC0rycxX2A1NqrJd/EJiFU+TtrxyfRzbWyujN
	FTE67GtH3V8KTZllOWQPSD8T/xiuxn2Pw2x1CxXpBnoxWYRg05hubeBMyO4Mc6on5TRqxza0M7y
	+ULfBGUUBlUbnqKi2HiaOFOz8Si3tdB8C4ObK0D6n7s1IhwLkBtqXY6+SQcrlGaS2Jo9dIyi6pS
	Qh+Bzsmlhrajx12/grGsWRDvHtv7x3VzcOkZCHnwAHqfHnH8rNvuydhf1GBY0KefQkDxhswAPwp
	8uIiJ1jQdUjctZbVIne6aZ8Ad9QCI6NvYNHcxkdpMUqCnBWQF8mZ+KqNkm8WfvKOL8T88JB/FE6
	lUPJuP3IEmSLGsJqS8jJ9vhEXFXDjPng0i0PmWCh8mDibDhLHur3qI7NONmKhl2KjA4vE9DaSny
	ufB0IQJABrJsQfVj5RSpNm8h49W8KsQBSsIXA33cSImWMohLQcLdP3aheAB30vHUzvrxtBPDiR3
	d0HMIFBHpQhQMZK1Ib+SmZ9//f1jE3NUS72fpHo6R4AAeDIWhMuZriwhXJLo40eb0uBOvrVgd3U
	FHtKw4lm/d0Gya5BVAUJQ+QbrzwJLEDc68gmsIXWumsOzyfuDA==
X-Received: by 2002:a05:6000:288a:b0:48d:f9c1:2ad4 with SMTP id ffacd0b85a97d-48e5d460118mr13343516f8f.4.1793282062814;
        Thu, 29 Oct 2026 06:54:22 -0700 (PDT)
Received: from L-P-ITAIH2-L-RF.rf.local ([193.169.70.108])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e3ebd48e0sm35032983f8f.38.2026.10.29.06.54.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 06:54:22 -0700 (PDT)
From: Itai Handler <itai.handler@gmail.com>
To: Zdenek Kabelac <zkabelac@redhat.com>
Cc: lvm-devel@lists.linux.dev,
	David Teigland <teigland@redhat.com>
Subject: Re: [PATCH] label: fix writes when the logical block size is not 512 or 4096
Date: Thu, 29 Oct 2026 15:53:55 +0200
Message-Id: <20261029135355.3690645-1-itai.handler@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <e297d16a-58e9-40b2-9f1d-8baaf29e823e@redhat.com>
References: <20261029125312.3631129-1-itai.handler@gmail.com> <e297d16a-58e9-40b2-9f1d-8baaf29e823e@redhat.com>
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Post: <mailto:lvm-devel@lists.linux.dev>
List-Help: <mailto:lvm-devel+help@lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
List-Owner: <mailto:lvm-devel+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Zdenek,

On Thu, Oct 29, 2026 at 02:12:34PM +0100, Zdenek Kabelac wrote:
> Hmm - this thread io engine is surely a new logic we are putting in.

This is not related to the threads engine; the warning just names the
engine in use.  On main, pvcreate fails the same way with io_engine
set to sync or libaio, and also with releases from before the threads
engine, such as Ubuntu's 2.03.11 and Debian's 2.03.31.  Built from the
release tags, 2.03.05 works on 1024- and 2048-byte loop devices
(pvcreate, vgcreate, lvcreate, vgremove), and 2.03.06 fails on the
2048-byte one from the patch:

  # pvcreate /dev/loop8
    Error writing device /dev/loop8 at 4096 length 512.
    bcache_invalidate: block (3, 0) still dirty
    Failed to write mda header to /dev/loop8 fd -1
    Failed to write physical volume "/dev/loop8".

The cause is 7f347698e3d0 ("Fix rounding writes up to sector size"),
which went into 2.03.06.  Before it, writes were rounded up to the
physical block size, which is never smaller than the logical one.
Since then only 512 and 4096 are used, and when neither block size is
one of them, it falls back to 512.

> I'd like to know more details what is the scenario we are trying to
> solve - normally we expect devices to really have 512 or 4K writable
> blocks.
>
> We have some set of patches to improve support on systems with 64K
> pagesize.
>
> But I'm puzzled from where do we get  1K or 2K block sizes ??

I ran into this while testing LVM on dm-crypt with sectors larger
than 4KiB.  A dm-crypt device uses its encryption sector size as its
logical block size.  dm-crypt has accepted sector sizes from 512 to
4096 since Linux 4.12, and my kernel change 1acc65c30f85 ("dm-crypt:
allow encryption sector size up to PAGE_SIZE", target version 1.30.0)
raises the limit to the page size, so on kernels configured with
64KiB pages it can also be 8KiB to 64KiB.  pvcreate fails on all of
these, and while looking into why, I found that 1K and 2K fail the
same way on any kernel.

1K and 2K block sizes are not common, but they are valid today:

- cryptsetup has offered --sector-size for LUKS2 and plain devices
  since 2.0.0, and accepts 1024 and 2048.  For example, pvcreate fails
  on a LUKS2 device made with "cryptsetup luksFormat --sector-size
  2048", and LVM on LUKS is a common setup.

- s390 DASDs can be formatted with 1024- or 2048-byte blocks
  (dasdfmt -b), although 4096 is the recommended size.

- loop devices with --sector-size, which is the easiest way to
  reproduce it.

The 64K page size changes already in main, such as 3e91a5265
("striped: allow stripe size smaller than page size"), were in the
tree I tested, and do not change this.  If you have more that are not
in main yet, I'd be glad to test them on my arm64 VM with 64KiB pages.

>> Fix this by rounding up to the logical block size of the device when
>> it is neither 512 nor 4096.  [...]
>
> I think we want to fully hide this in blkio -  label layer should be
> above.

Agreed, blkio does the direct I/O, so it should know the alignment it
needs.  For example, it could get the logical block size of each fd
it is given (BLKSSZGET) and round shortened writes up to that, so the
label layer passes only the offset.  For devices with 512- or
4096-byte logical blocks this rounds exactly as today, including
those with a huge physical block size, as in
large-physical-sector-size.sh.

> So I will think more about this.

Sure.  I can send a v2 along those lines, keeping the test, or test
your version if you prefer to write it.

>> Devices with other block sizes are uncommon, but easy to create: loop
>
> Can you tell why do you actually need to use this blocksize - IMHO it
> must bring some inefficiency ??

I agree that blocks smaller than the disk's sector, such as 2KiB on an
SSD with 4KiB sectors, are inefficient, since a 2KiB write makes the
disk read and rewrite a whole 4KiB sector.  I don't need those myself;
I mention them only because they hit the same bug.

What I want is the opposite: larger blocks, from 8KiB up to 64KiB,
for dm-crypt on kernels configured with 64KiB pages.  These are whole
multiples of the disk's sector, so they do not have that problem.

Whichever size is used, the cost to LVM is small.  Only LVM's own
writes, such as metadata updates, are rounded up to whole blocks,
which adds less than one block to each, and they happen only when LVM
changes something.  LV data does not go through this code, and the
default 1MiB pe_start keeps extents aligned for any of these sizes.

Thanks,
Itai
