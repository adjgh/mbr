;------------------------------------MASTER BOOT RECORDER---------------------------------------------
;------------------------------------2017/11/1-----------------------------------------------------
;----------------------------------WRITEN BY LIANGYAOSHENG-----------------------------------------
assume cs:code
code segment
org 7c00h

     mbrstart:xor ax,ax
	           cli
			  mov ss,ax
			  mov sp,2ffh
			  sti
			  push cs
			  pop ds
			  push ax
			  pop es
			  jmp true
;----PACK-------
DAPACK:  db 10h
reserve: db 0h
blk_cnt: dw 1h
phy_add: dw 7c00h;offset
phy_ad2: dw 0h  ;segment
d_lba  : dd 0h  
          dd 0h
;---------------
			
		true:mov si,7c00h
		      mov di,600h
			 mov cx,200h
			 cld			 
              rep movsb
			 mov bx,631h
			 push es
              push bx
              retf			 
			 lea bx,offset DPT
			 mov cx,4h
seek:		 mov dl,[bx]		  
               cmp dl,80h ;检测是否为活动分区
			  jz load
               add bx,10h
               loop seek
               call errr	
			   
load:		call RD_SECTOR
               mov al,2h
               out 92h,al	;打开A20地址总线		   
			  mov bx,7c00h
			  push es
			  push bx
			  retf
			  
         errr: call errno
		       hlt;停机，等待中断唤醒
		       int 18h ;如没有找到系统活动分区，选择启动媒介
			   
        errno proc
		      push cs
		      pop ds   
		      mov ax,0b800h
               mov es,ax
			  mov cx,17h
               lea si,offset stb
			  sub si,7c00h
			  add si,600h
               xor di,di
do:            mov al,[si]
               mov ah,2h
               mov es:[di],al
               mov es:[di+1],ah
               add di,2h
			  inc si
               loop do			   
               ret
		errno endp
			 
RD_SECTOR proc
       push bx
	  push dx
	  mov bp,offset DPT
	  sub bp,7c00h
	  add bp,600h
      xor ah,ah
	  mov dl,[bp]
	  int 13h
      xor ax,ax
      push ax
      pop es
      mov ax,201h
	 mov cl,[bp+2];扇区
	 mov dh,[bp+1];磁头
      mov ch,[bp+3];柱面
      mov dl,[bp]
      mov bx,7c00h
      int 13h
	  pop dx
      pop bx	   
	  ret
RD_SECTOR endp

  
  db 240 dup(0)
  stb:db 'Loading Windows Failed!'
  diskname:db 92h,9dh,0aah,9ah,0h,0h
  DPT:db 80h,20h,21h,0h,07h,0feh,0ffh,0ffh,0h,8h,0h,0h,0h,0e8h,0ffh,4h,0h,0h
  db 46 dup(0)
  endd: db 55h,0aah
code ends

end mbrstart

;-----------------------------------------------------LBA模式------------------------------------------------------------------------------
;           OFFSET                     SIZE(BYTE)                              DESCRIPTION                                                |
;             0                         1                                      size of packet(16bytes)                                    |
;             1                         1                                      always 0                                                   |
;             2                         2                                      number of sectors to transfer (max 127 on some BIOSes)     |
;             4                         4                                      transfer buffer(16 bit segment:offset)                     |
;             8                         4                                      lower 32 bits of 48 bits starting LBA                      |
;             12                        4                                      upper 32 bits of 48 bits starting LBAs                     |
;------------------------------------------------------------------------------------------------------------------------------------------ 

