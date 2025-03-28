Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 181B913DBB1
	for <lvm-devel@lists.linux.dev>; Fri, 28 Mar 2025 13:20:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743168044; cv=none; b=jeNH1JcjBqk0V82YkTpG97SFR3IAUw0QNfGxSYS5ri1BNseV5sixBDfU0N2Cwuba/7xIkjgHMRsYqwucaACoOnWIjkG18BmJ2UOPbHUkspSTYQhoxDF/xCDuqRLrC+9aDOhBW5z1zhITmwjgP8NVM9j3fdRkqe9iZt7e1hVmdAQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743168044; c=relaxed/simple;
	bh=TJmfWgwP5Z5j/rPEoKh0WzsxSeqEruIUDNqfbJhyDmA=;
	h=From:Message-ID:Date:MIME-Version:Subject:To:Cc:References:
	 In-Reply-To:Content-Type; b=K99/FmigasDUf2oN+9shvkxmd6rYEgkjQKwnNThQ74PImhf7mZCdm4/JVaA2fOBj6ob8wIACU1A7iQZIMzCQsX1DaTwYljpPjs0zlC0v0EmokUiLx3gH5hUNFtd3BJNjiOZkV0kGk7vmDXbCliOVdHVE0m2QdaNPIrQMJBBJbSs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=LCVzCs+t; arc=none smtp.client-ip=209.85.221.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LCVzCs+t"
Received: by mail-wr1-f47.google.com with SMTP id ffacd0b85a97d-3913958ebf2so1713996f8f.3
        for <lvm-devel@lists.linux.dev>; Fri, 28 Mar 2025 06:20:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1743168041; x=1743772841; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:content-language:references
         :cc:to:subject:user-agent:mime-version:date:message-id:from:from:to
         :cc:subject:date:message-id:reply-to;
        bh=+l1lDUmNUESV0P6A49qguSuzg0b2T7euxvi0LRqQBOc=;
        b=LCVzCs+trXWo1ImT+seSR4bob65viCqaEIhR6inSsDGlPdhByRDyGfu/IdXzfQvxmO
         1bGJVuvoSxzOrltbEHJwTrZGqun4OeTdY8OYEsK90I1pS5GjLhj1gXiqfUSiLAoZjUmy
         kTZi8xhdArrAHfkcgDuddS4dRevINe2IUcudOPp+XSKvoKoeCaTDoQ08/gyqgA5DPyx9
         SvmIZtFeLLD320N3VaWkTevFQW96nGVKm986pBUl1kRCinpVOaQKt+rdz9MYnvhtsTmT
         bFrCyHAeKzfyy4H3EtyTJ9jAaQMe/fMnX/9o3Fh51A5Is3yhPsUYgq064w6bnDt4Frac
         jCJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1743168041; x=1743772841;
        h=content-transfer-encoding:in-reply-to:content-language:references
         :cc:to:subject:user-agent:mime-version:date:message-id:from
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=+l1lDUmNUESV0P6A49qguSuzg0b2T7euxvi0LRqQBOc=;
        b=tHZBWiqNhfVh0Deqzv4w4QovOsYgy0DwkMGiVoTPXgb+8e6uwQ3/OGoQfmFmTtkRGX
         zX0+GMmMU/T/tD4Ar7nDnCjAukq1VoxBoqtAUFDI4l81auJiPsZf/e1uUHvfLN9vsVp8
         KgkKvCwBk+4o5bgz8ATvBCnyZq5iurJVmliXC4Ct1mWF+I/yZhYPaB4+i+wiAS+rb1Kt
         hLxII7aHmwcQiF+byMUMUqpiNnCvTp58xuxrBQV3oNb983gy8XbBGfKkEbjbG4Y4erQx
         YSvKdikn52gshPFub+OPj9bXohF0qhaL9OL6mMvFJYruF20rb7vLL94kQeVeQatc1yDV
         JTZg==
X-Forwarded-Encrypted: i=1; AJvYcCXjLlLqdW94aoQS3oNzt843tb425v98MgY+vRNqdB+PT/S8GAuG3AF+v3Y88oX3bTcNJiSv1Ljhw1o=@lists.linux.dev
X-Gm-Message-State: AOJu0YxdY1bHkuhTxY57qx2ZIsGx2NdRYi2qx/CHdSeShty8/ZPdex40
	tIZT0k/ZMHzMgigwIB1qfZbCEehkJDpKLSbkbNWAnTBTQxFZeO3ETIbHizrAoLM=
X-Gm-Gg: ASbGnctfx20++SctHi7R44i0J6aao4iiDMLvoxEPWfiEd8/22WR2Fgs9rkwiuRxkQlD
	z6fbPpak/DSAd8bcnO2pcC/TDoar0Ax2IAF++Bm5psfSWXLSxFQZHASyJ9Jcu5QM/zTzx/7nCyh
	ixgWKmRRSndVkuqbSNeuCplXquPKQaamcWmeD5q2eO4ZOOrcnvCF/E7RQSBhNH3zEjEl/nwzc+h
	EPCSwxr2sSwNobJqCvg9mL/NWy7blz3qY0naa7WRwEEOf3ThJ0v2dypZB8THjh9z6N3cfE7lOkO
	4y/GRGe8x3KtES3/0yenUsDlMGyyxD91jHDUq/zjgUpOWaiJO+fHeUhHQC1VZhHrR5rX8u74VcZ
	PEdY1/zznjtUM1DhD
X-Google-Smtp-Source: AGHT+IFKVedvCXkWjOkSTjO1i92jeC19hIDjXuCDgY7CFpptrSH4eTPxT7TCUtkLdsCf9oPJcIM6ew==
X-Received: by 2002:a5d:5f42:0:b0:399:6ad6:34 with SMTP id ffacd0b85a97d-39ad1760701mr8350713f8f.35.1743168041058;
        Fri, 28 Mar 2025 06:20:41 -0700 (PDT)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-39c0b66a8d4sm2589705f8f.45.2025.03.28.06.20.40
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 28 Mar 2025 06:20:40 -0700 (PDT)
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
X-Google-Original-From: Zdenek Kabelac <zkabelac@redhat.com>
Message-ID: <b73759a3-a450-4e97-add0-2c8351b60f69@redhat.com>
Date: Fri, 28 Mar 2025 14:20:39 +0100
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] lvmcmdline: cleanup tab
To: long.yunjian@zte.com.cn, lvm-devel@lists.linux.dev
Cc: mou.yi@zte.com.cn, ouyang.maochun@zte.com.cn, jiang.xuexin@zte.com.cn,
 xu.lifeng1@zte.com.cn
References: <202503271658587110eSppwPsg21ncwifiIKCh@zte.com.cn>
Content-Language: en-US, cs
In-Reply-To: <202503271658587110eSppwPsg21ncwifiIKCh@zte.com.cn>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 27. 03. 25 v 9:58 long.yunjian@zte.com.cn napsal(a):
> From: Long Yunjian <long.yunjian@zte.com.cn>
> 
> cleanup tab in _get_current_settings
> 
> Signed-off-by: Long Yunjian <long.yunjian@zte.com.cn>
>

Hi

Common do you think a single empty line change is something to bother with ?
Are you trying to get your email address to as much projects as you can ;) ?

You can certainly find a more worthy addition to the lvm2 project than this one.

Changes like these are 'squashed-in' when the code around is somehow reworked,
otherwise it may just case more harm than good - as them potential fixing
commit later might fail to merge on backports - so we do not commit such 
'empty' changes unless necessary.

Regards

Zdenek
