Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA091181817
	for <lvm-devel@lists.linux.dev>; Mon, 25 Mar 2024 09:33:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1711359204; cv=none; b=iu0MYDrnpqlCYDjZyqh0IIxBKw1aGJbFgnI7F7Y/KXF8Ybgz3fK4AIn0NJWs2Km9IIfYNMoYrTiaL9tl0nLFQ/820Htr9eB+uOm77kMmpnhElwrw8tFlFze8Pz+blwDj/IIEz/fzCDpyMCX01BOqH9rnZgeth/qu3IBGqiVDPEk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1711359204; c=relaxed/simple;
	bh=vqRQkc83ZKTpUipa9aFTJX8iqhq96RJHwlXp8pq+d8U=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=jUPsQR74bYfqAOUelL0xzqbzluA0MpKNdmGC92UpWKxObUiZkv0oWxdbccio9I0+iajoTaUnZ3F3PObyOWSS+zb01pEpEofYSjsWnzEPXSDMlcCmwSuOpEPEprdRR8+uA2PjpdjDvQFZJoLkZ/03RIrikiHi8HKL4KE23/sesJE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=PcJjKui8; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="PcJjKui8"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1711359201;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references:autocrypt:autocrypt;
	bh=KjXx/HKx/1wv2/YJsZZ6VAL+opl+61oSGioXg0uKIKc=;
	b=PcJjKui8AbsgkR8sGXccddX4L9ODYMJMiQiK04liM3Nme9fkKXtoLYMS3ZSemQ6OKoARD5
	sQSjQLs1OEaGyMPMchdZbnqMVUKir595PNBvyIZvn7WK/kvhAmbTk/MxXFvXRa0vhMkhcR
	3I+sT5H/6aU9F5kmmGVhSZ5sVRipemo=
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com
 [209.85.167.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-484-Dmgr72AIMEeze6knkZdmWg-1; Mon, 25 Mar 2024 05:33:20 -0400
X-MC-Unique: Dmgr72AIMEeze6knkZdmWg-1
Received: by mail-lf1-f71.google.com with SMTP id 2adb3069b0e04-5158a80cf1aso3675834e87.0
        for <lvm-devel@lists.linux.dev>; Mon, 25 Mar 2024 02:33:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1711359198; x=1711963998;
        h=content-transfer-encoding:in-reply-to:autocrypt:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=KjXx/HKx/1wv2/YJsZZ6VAL+opl+61oSGioXg0uKIKc=;
        b=Xas1ge3F2D+T3QtfwVw4ZBjWlQf8EeYfOUxuffuMelI8P9VWyl032L/yQKqohGdAYv
         Qde4Q9I07hcr8f0qHeFv9GCDDge/1pdMmIcb6YYb5Pdn09/eY9GcQNIEpmC4F275ftuf
         O2xrkAkuHsmz+GdmjCZwyJheiAVsZw1fVnsispSA1iPjOkk0/qPifKllKS8T8fkb9tCk
         Aw2KfFjGZ5D34Po/g0qCHizj1SCgr3GxqwHUhLUqNSqewGOKwDjwT+ylT81PujvJlLtm
         Y751qivstbCMM+G3P5kbpxS097KSucA6+G3E7c/KKGFB9DPTP+dqdstgjLl2kJhFmNZ+
         rNFQ==
X-Forwarded-Encrypted: i=1; AJvYcCVptILsS3tVMLe1EWEc+iPVY4smYZ8XlheOIB6o3hh+jZ3Av0Is27TnttRkUDf5E+Qgt0WXTwe2n/VMkVQPw7gXjtG9BosmNQ0P
X-Gm-Message-State: AOJu0Yy8lwg2ON8XSXysNyb4SyyEPgceZjHGsJncGdchMp0zZryGaGBx
	/zwLeFg7rVal7ETUXCTy/bn0d0k8ICvNKGW8/ICsBRpmMip71Jo5dpH6hWe4lMRNJucqQ8jr+f3
	qBsHWEnCujtChgO7MTADjtsHav2NP8b600wEZR9MEA4oamIkeFAxIL5KmBg==
X-Received: by 2002:a05:6512:53b:b0:513:4105:6b34 with SMTP id o27-20020a056512053b00b0051341056b34mr4071929lfc.64.1711359198604;
        Mon, 25 Mar 2024 02:33:18 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFq4FSdrJvTmtTkMk/10LF+JBisIfGo3lcLy5H0irOXZ0TSjL2zs3iRKLL1PJfXepjqcZgY7A==
X-Received: by 2002:a05:6512:53b:b0:513:4105:6b34 with SMTP id o27-20020a056512053b00b0051341056b34mr4071920lfc.64.1711359198264;
        Mon, 25 Mar 2024 02:33:18 -0700 (PDT)
Received: from [10.43.17.192] (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id q2-20020adfcd82000000b0033e7603987dsm9043420wrj.12.2024.03.25.02.33.17
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 25 Mar 2024 02:33:17 -0700 (PDT)
Message-ID: <4d6e9fa9-b777-4373-a880-f24f529bc109@redhat.com>
Date: Mon, 25 Mar 2024 10:33:17 +0100
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: udev rule bug: LUKS on LVM doesn't expose labels
To: Patrick Plenefisch <simonpatp@gmail.com>, lvm-devel@lists.linux.dev
References: <CAOCpoWfYjOVNJNt+cnOVXDHiDq2wRogTqBijcUoa7chqOLRa5Q@mail.gmail.com>
From: Peter Rajnoha <prajnoha@redhat.com>
Autocrypt: addr=prajnoha@redhat.com; keydata=
 xjMEY7QY9hYJKwYBBAHaRw8BAQdADIHZn5yeZYFV18ewwf4iudpl1ARfj4rnxX5xiSoJ15vN
 I1BldGVyIFJham5vaGEgPHByYWpub2hhQHJlZGhhdC5jb20+wpYEExYKAD4CGwMFCwkIBwIC
 IgIGFQoJCAsCBBYCAwECHgcCF4AWIQQhe3cZL8e9dSzFIwXndmZANt+EqwUCY7QZ9wIZAQAK
 CRDndmZANt+EqzosAQDXhWudIjLSGoWGPKgluEWw5B5LtAX+kW2OG7loCDzI2AD/fp3Xec8K
 JY7HrSqO98YMPbT98+YRjiopJSk75TcAogzOOARjtBj2EgorBgEEAZdVAQUBAQdALfG8fuls
 uqLPtrJ5tYb36UtqNlu6Bw9ME/Ou+FRGG1cDAQgHwngEGBYKACAWIQQhe3cZL8e9dSzFIwXn
 dmZANt+EqwUCY7QY9gIbDAAKCRDndmZANt+Eq22lAQDXlKMGQxkD0FZes94uihIZlhFwGjrX
 dVfZsxfwEvuJfAD/XLGDegnKVERbF6YTfdsbVngSlOX/Tu/fxAFTg0JfdQU=
In-Reply-To: <CAOCpoWfYjOVNJNt+cnOVXDHiDq2wRogTqBijcUoa7chqOLRa5Q@mail.gmail.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Language: en-US
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 3/22/24 19:18, Patrick Plenefisch wrote:
> Hi,
> 
> I noticed that my LUKS-on-LVM setup wasn't generating
> /dev/disk/by-label symlinks. After some poking around, I realized that
> the udev rule doesn't include crypto devices:
> 
> udev/13-dm-disk.rules.in:40
> 
> ENV{ID_FS_USAGE}=="filesystem|other", ENV{ID_FS_LABEL_ENC}=="?*",
> SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"
> 
> In contrast, the uuid rule does support crypto devices:
> 
> udev/13-dm-disk.rules.in:39
> 
> ENV{ID_FS_USAGE}=="filesystem|other|crypto",
> ENV{ID_FS_UUID_ENC}=="?*",
> SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
> 
> Adding "|crypto" to the label rule and everything seems to work fine
> on my end. Is there some other behavior I'm missing here, or is this a
> bug in the udev rules?

Yes, indeed, it's missing. Thank you for reporting that!

Fixed here: https://gitlab.com/lvmteam/lvm2/-/commit/f09a9927207f81b33b9eee8ac5660d90e695dad1

-- 
Peter

