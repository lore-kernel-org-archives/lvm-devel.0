Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793535624;
	b=RsS2sXKjkzb7B0aXMCEZypD1MCiilnXMmucsrMZI/vrGo2KxSu/9zIc9IpeAf5WS/9am
	 osQNo2AwQTJ6aCOIUfmv8TIteEl/uSppOwUSQ+Fp6K6G1GJXj0/rJ9o5RiVU1U+mIPPhD
	 QnHjlQe9wkP00uDfKwlYhAZ1H8NAQk8ob4B1nmSmtUYeQ99KF8jIytrR9VuDak3LwGI4l
	 WqxMYoUX5TYejn60HJ5S+jfkQ/po05aOlWRJe81swuA89OG4dJx9yD6YZUmP/a5W4AvU9
	 utcPqRwpY090JILyTUxJ+JyDTJDee/QlLX+HsiSXJ18ev0/eyivn4hq4nVvuw12njtA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793535624;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=ic0aMEq6jTKjz0QNMrrPLnDV3KqA+UNl102+dcjwShc=;
	b=nwg0XFyUNCS2tIbWx6B5NvvL/gU+/d9NjCayNxbQsWSvipJZ495JiukTXcAGBPFYQKGu
	 pw8lbafHpH9HMJZjPtQm2aKkEl+sqoHyQQkUz5d3Jtsbd+oqnSGkqYTlLxH6/MZzV8L6Q
	 9GvPEnu0Ouxj5l5PfOaqYgEX2QJEY9xbg8YJygxHj2HRM3xV2kyC8JALwQZxmYH/CThIM
	 lbzjU0TGN0SstkbG1aeosP02ezcaZk9QYFfLCpue/RddYGKMZpTW4Su66pACZeLlyROHS
	 rRxUhj17+hrqhbGRVHskM8BMqIjGsJLnrYwCwZ3YNvxkgDkOY01xFuDbBzLxN+sRG8w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Kny0qmoo;
	arc=none smtp.remote-ip=209.85.128.45
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 48781606A324
	for <lvm-devel@lists.linux.dev>; Sun,  1 Nov 2026 12:20:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 48781606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=Kny0qmoo
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-4a5348aaba5so2730025e9.0
        for <lvm-devel@lists.linux.dev>; Sun, 01 Nov 2026 04:20:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793535623; x=1794140423; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ic0aMEq6jTKjz0QNMrrPLnDV3KqA+UNl102+dcjwShc=;
        b=Kny0qmoo0DO/IQ0ZSwtvXegYxBuE8PMINwLJpSqpgXFrLfUweV7lacjfffXT2AhnVn
         BWEnGt3RwyX/8RQ+Y+bnIR5zZAbtz2VzYDDsb9fZAJcJIA0kxPwizuR6Eiq7trUEaRzQ
         bVA9gzoUxs1ENYxqNl8P172LK3+KXL/DWuN4ddOr48A+9Ck07V9FgAb1wXZDxLB77T2Q
         pXEobZ3bEROrXtwAh1/Gb1pGWACGHeRFYtK0pmhqP9+bp7ke8aSlIsiKMXGpPw7VRiL4
         8pVBt0Dwm/HO1E2ScKAjvOKmAwynGXs6RT+2hOz9xCmHIxLYZfQuFGjVUHU0yPsjj3wT
         Pjkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793535623; x=1794140423;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ic0aMEq6jTKjz0QNMrrPLnDV3KqA+UNl102+dcjwShc=;
        b=gACm6cuYKdIW9FcTDbD5BDQwj+PqTnWWsgkXvFGXFsiIA6SIQt+/7gF6GK3ry2elxD
         BFlZlVRsan1tR4Unw5meKTz9J96BbeaY5a+/34f0yaRsO8uT9NHMB30NkWZd30VxjKrP
         JZqq9f5IRoMJOB6AY30a9WhVtp4IADazl8F6KDBjgQ18UrIWCEyX5Gne9p0bf/N4z75X
         jVysc583cJ6YqtNrWglKeUOPGhaBtxFtIj+KJ3Mug10KTmGivdPRM2xmUEoeJDYZrhW1
         +3EjH9lAYN8IQClRpvL2PYGNHkfDKzm6oTTysGf1qgiiiNtbvaT0zLXMIcQ+wLaztNku
         X9Hg==
X-Forwarded-Encrypted: i=1; AKwUvBxDmjnUb6eYKrE/AjNH9RWaFitZ1jLcVs+USWLPkBL+VKSTUt6ne8fRJuetkJc7ehZgQ+wF0of09vM=@lists.linux.dev
X-Gm-Message-State: AFq9FYLOsoaq9bZyqCrsT1paj8kQnbtALMJx0LMt0QfsUIE3IW+W8/3H
	3RCwfqpWI0nsfDgBUvy6S6FUoolNNzESNKbcRPkvzQXOW6nzgmAMcw1O7i2EYQ==
X-Gm-Gg: AYBFou0FIEltZCaAmebI7KFg2rAZ8rVfwWJ65XBQdqWFkzWTRTJfOcFkOksES1uHnt5
	WAzX/kKB4ywVX87VSBb1NpbMZavQAPoHV1zSqmAiHW71yOLXbj+8aDfQqvvJZ2Y8chDu8nSDuxf
	2O9y5evhgG8JXZ9dlnr4IAAsjU8qjfasvbAjkE8iwxGQg3xbQw9kSHJ7dbsexgV5n7sOar+6rCH
	t6GTKnoNoMdYwv5FOw/fh+CYa5zOdniIXX8fqq1qNS2Oyh1dUeJ0AKaFLAADhKmpAZ9ddlIoKe3
	D5/8euoeRcks46N8PfDDsQw+qcph9DU85pTKWzVF7UBo2pdmsE9SfYjeOBPQd6bbV9zV4lxt7ur
	gDGXba1blBHwWmBGRaBf1+5OodTJE29Tl8KS6BWLt3fEiwZKyTt30Jv0DW177aROIMTyRb0VOsl
	Wv02WBVzaSFg4+Sa7xHflstbVmgN4RNNW2vML8sV/k6iE+c0d1HbuaO+eIG+aPg6sCxqqAyVxP5
	AI/tOpjY2brwqd3/M0aFxTy53qxBKWEYXw9pKmNj7BhFb+sliKvETA8sbxWawxdD5fQYFH6pYsL
	32py03Si+kZg4T786y6nE935nBUtYyZ01Pw/aMqcR22Yi5obGw==
X-Received: by 2002:a05:600c:a293:b0:4a2:417:7db5 with SMTP id 5b1f17b1804b1-4ac17d19a54mr108969715e9.2.1793535622464;
        Sun, 01 Nov 2026 04:20:22 -0800 (PST)
Received: from L-P-ITAIH2-L-RF.rf.local ([193.169.70.108])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e71a4d4f9sm14234940f8f.2.2026.11.01.04.20.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Nov 2026 04:20:20 -0800 (PST)
From: Itai Handler <itai.handler@gmail.com>
To: David Teigland <teigland@redhat.com>
Cc: Zdenek Kabelac <zkabelac@redhat.com>,
	lvm-devel@lists.linux.dev
Subject: Re: [PATCH] label: fix writes when the logical block size is not 512 or 4096
Date: Sun,  1 Nov 2026 14:19:43 +0200
Message-Id: <20261101121943.1867919-1-itai.handler@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <auOUULF672SkVzt8@redhat.com>
References: <20261029125312.3631129-1-itai.handler@gmail.com> <e297d16a-58e9-40b2-9f1d-8baaf29e823e@redhat.com> <20261029135355.3690645-1-itai.handler@gmail.com> <auOUULF672SkVzt8@redhat.com>
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

Hi David,

On Thu, Oct 29, 2026 at 01:45:36PM -0500, David Teigland wrote:
> This last line touches on the main concern I have with the rouding up.
> dev_set_last_byte was added by aecf542126640faa17c240afbb1ea61f11355c39
> which addressed a very subtle data corruption bug that was introduced
> by the bcache (now blkio) layer.  In order to safely round up, we need
> to be certain that no VGs exist in which that rounded up space could
> be used by LV extents.  In the past (less so today), the pe_start value
> could be highly variable due to several config settings or command
> line options.  We'll need to prove that current and past versions of
> lvm would not have placed pe_start within the rounded-up space.

Right, my last line only covered the default pe_start.  But I think
the kernel makes rounding up safe for any pe_start, whatever version
or option chose it, as long as lvm rounds up to the logical block
size and no further.

Rounding adds the bytes from the end of the area being written
(label, mda header or metadata area) up to the next multiple of the
logical block size.  An extent can't overlap these areas, so if it
holds any of the added bytes, it starts among them, between two
multiples of the logical block size.  device-mapper refuses to map
such an extent (device_area_is_invalid() in dm-table.c, since
2.6.31), so no active LV can write those bytes, and writing back what
lvm read there changes nothing.

For example, with this patch, on a loop device with 2048-byte blocks:

  # pvcreate --dataalignmentoffset 1k /dev/loop0
  # vgcreate vg /dev/loop0
  # lvcreate -l1 -n lv vg
    device-mapper: reload ioctl on  (252:0) failed: Invalid argument
    Failed to activate new LV vg/lv.

and the kernel logs "start=2050 not aligned to h/w logical block size
2048 of loop0".  pe_start is 1049600 bytes (sector 2050), so metadata
writes that end there are rounded up 1KiB into the first extent, but
no LV can use that extent.

However, main doesn't always stop at the logical block size: with 1K
or 2K logical and 4K physical blocks, such as dm-crypt with 2048-byte
sectors on a 512e disk, it rounds up to 4096.  If pe_start is a
multiple of the logical block size but not of 4096, the first extent
can be active, and a metadata update puts up to 3KiB of old data back
at its start.  I reproduced this lost write with scsi_debug on main,
and with Ubuntu's 2.03.11 and Debian's 2.03.31.  It needs an unusual
pe_start, so I doubt anyone has hit it.

So I'm sending a fix for that first, as a separate patch on top of
main: "label: don't round writes past the logical block size".  Then
I'll send v2 of this patch on top of it, with the rounding moved into
blkio as Zdenek suggested, using the logical block size of each fd
(BLKSSZGET).  Compared with main plus that fix, v2 would only change
devices where lvm can't write today.

Thanks,
Itai
