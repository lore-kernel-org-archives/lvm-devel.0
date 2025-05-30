Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C246A19AD70
	for <lvm-devel@lists.linux.dev>; Fri, 30 May 2025 11:13:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1748603598; cv=none; b=CwBvOHOYa+LsOhtPNNIoz3P2HK+jNduz0Eb3RRDSInZQbIk0Ue528VklFAq46SWIwXrNk/WZuXwsykd62c/jP+DL8QMiKhLCoHtT7llat2q+DricnronOsGozM4+Adm+gUOCEPGhdr2SW/UpDLiz/VkmnTfKV9gTMUFH1IXwa98=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1748603598; c=relaxed/simple;
	bh=zV4Ae9AtjX09RLqqD+bwxuJyAa0GIkOvZVgVTeHpho4=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=dVCmhqG6aUqYZNujT5cLzNG7hj5KWklVqdNXq/SO/Kv3Kv0gW23UEPbGFxicL68IsrajONgkuq4RFq8cuhF/EEhw0YbmiSY6Hb3CbEF6AFBgH2gWDfcCajphY8yjLi0WRv7dpuL9uTIfK1qIeIqCvXmzjeNMjIrFd1qwdmxuplM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=IlAhL3Ha; arc=none smtp.client-ip=209.85.128.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IlAhL3Ha"
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-442f5b3c710so15792275e9.1
        for <lvm-devel@lists.linux.dev>; Fri, 30 May 2025 04:13:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1748603595; x=1749208395; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:newsgroups:to:subject:user-agent:mime-version:date
         :message-id:from:to:cc:subject:date:message-id:reply-to;
        bh=Rcz6KlP35CPqdcLAbduLzdRop6T8+EFEjdi9FtLYE2k=;
        b=IlAhL3HabB32ElDM/SEy/4Wrz6zyv933CfnWKarGTkuXkmzA0BZKXKI0SZ0jS3QTAl
         kcS8YRYNZQHZ0hl4ePVN6EZdaEfeiak0m+f/W1V861/7gKzInsL8rLENgCZZmn0UOdl1
         PVBeN5BeG9zSCVoRiYKHAiDJ7amEvme6PN5qU/Y5FWLnxf+pBmNzI1gW9vq5REB5QABS
         IBKmIrzVd377I2LR63jRGKUK4DMDQqisFDY88yVKM1EvdeHG0tML1qsNQ8MSVUFOZWqn
         wCYRjUfPrr9O0rPUz5dn+KkNarBBELapRv8ePEIvQnPt8Xh2+PB5Her/oDxQKaOu+lfP
         rMwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1748603595; x=1749208395;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:newsgroups:to:subject:user-agent:mime-version:date
         :message-id:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=Rcz6KlP35CPqdcLAbduLzdRop6T8+EFEjdi9FtLYE2k=;
        b=uVZWFCKurMJCnf+7eOJdPqrq97aB7ejPsWfrDRla5HYwfV1NaB1c27hle+qq4bYVYM
         b24mTwicu+SMDAM3iWNxM3v6/Ncl4pfku1CEptlM5/BagxW3zjFNayuY9EZM0Wh2VTGa
         C9qN0GnRByxva6/vHHRcNKWW0hLLiVF4+rQRYaVYuA8+XvTRIZZp3ddNzSwcYC7nRW6h
         /FyHN2DHUsWVtP/qzzbcBIpSOxjc67R53ABKbKOYmy89wr4DEa8r6X5pVsNj8gEK5yLs
         PIBHRje+JXq/d9xc7etIe7HeU7KHHZ7rltd63HXPhPuqbASIK0RWjJRz3ii0AnRhaL/U
         oxkw==
X-Forwarded-Encrypted: i=1; AJvYcCWvipl4/1GQTqvrkUv9OBT3n7BEzCzC0UkjSwUKvxvixVis35lAsCIn75bdaCap3W5SMNnuqR1DfHw=@lists.linux.dev
X-Gm-Message-State: AOJu0YxD/v3F0cZA5Zy5PRs0DfILGHEt8/Plul1v/TWJKhhKYf1hySRt
	QxauiebDJbPLjNU0O5zh+iNY9EenORWRG/m5IY53dXqMnxYHKaYCunGz
X-Gm-Gg: ASbGncvSh2Qn31A8veuMRxcMkQJjfbCZNpv5EfDIkEnkHSXSXyUruM3Kv/4zT5i49KW
	hNgmdRbgFYp0QIpmoZRRd/3IQy25YKOK7fF1fjHD9u6pGYB3QPkb+oZU8g0MEPiv1rsNYQJbBUW
	6CGQXWYzC4fV3yCcmeTOskyVEl11uSey5qEblYYU/I8++jp9S7+OBQVYbZxMsEHRotEWDi1xADj
	3RS8TVGCZO8bdnNAqQBw8rmfwnetBabGjyIbFYOyVipbGuOIrze6vrmJiEcv/CYCaVho1UXIOj3
	N9UtQzyo3sx2XO5csggtlmq4S601EUzdU30a+0ulG23rje60u8gSlK3RX8H0mR1XDyOK/uXKx3a
	jfF5YNFTPRryjeZOPB3o+huMyP9JwfPEFoGliyg1M
X-Google-Smtp-Source: AGHT+IGhbaeT3Xm1iSaELVDz5ZvP3piR3vBWfPAwFZUGg0cvmr3xuId92g4mfQqDIIqRP/g9HmJ4Pg==
X-Received: by 2002:a05:600c:524f:b0:450:cfe1:a827 with SMTP id 5b1f17b1804b1-450d6597e23mr34322545e9.31.1748603594656;
        Fri, 30 May 2025 04:13:14 -0700 (PDT)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-3a4efe73f3csm4457162f8f.42.2025.05.30.04.13.14
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 30 May 2025 04:13:14 -0700 (PDT)
Message-ID: <1bacbf89-a28b-4ff1-accf-227f3a1567c1@gmail.com>
Date: Fri, 30 May 2025 13:13:12 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Reg LVM PE Size and any limitations out of it
To: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>,
 lvm-devel@lists.linux.dev
Newsgroups: gmane.linux.lvm.devel
References: <CAHJKXw3v-UUwg1sAvYThJMZHi5GBvqvHpaDVSYaVcLGTe048Lg@mail.gmail.com>
Content-Language: en-US, cs
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
In-Reply-To: <CAHJKXw3v-UUwg1sAvYThJMZHi5GBvqvHpaDVSYaVcLGTe048Lg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 29. 05. 25 v 19:06 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> A very good day to you.
> 
> During vgcreation there exists a field '-s|--physicalextentsize'.
>  From the man pages it calls out as extent size of PVs in VG.
> As a reference on a vg already created, I see that it is called out as
> 4MiB. [see below]


Size of volume group is defined as 32bit unsigned extent size x  32bit 
unsigned extent count.

The size is internally using 512b units and we can create a volume group
capable of creating  ~8EiB volumes -  user just needs to set 4G extent size 
(so then user is restricted in created LV size ->  4GLV, 8GLV, .... )

> My questions are as follows:
> 1) Is this dynamically computed based on the installed PV during VG creation?
> Given this cannot be changed after VG creation, what would happen if

ATM 4MiB is applied by default.
But since the storage sizes grow so fast - we may consider for really large 
volumes to pick bigger extent size (maybe 1GiB) in future.

(Also if you is planning to use  lots of LV - he needs to create bigger 
metadata area - as with default ~1MiB we can handle around 1000 LVs...)


> the pool were to grow or even the disks were to grow (think san
> volumes). would vg limit itself to some capacity limitations above
> which it cannot grow, leading to my second follow up question.
> 2) Is there any limit to the max number of PE in a VG?

Yep max PE count is  32bit unsigned  aka  4G


> It is not called out in any man pages, but an internet search gave me
> a max of 16M extents in a VG. So here I am asking for clarification,

With 4M extent size it goes like this:

Max addressable VG space is  4M x 4G extents  -> ~ 16PiB

If you need to use bigger volumes - you need to use bigger extent size as with 
4MiB extent size you can create at most 16PiB sized LV.


Regards

Zdenek
