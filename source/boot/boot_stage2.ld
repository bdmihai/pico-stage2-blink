MEMORY {
    /* We are loaded to the top 256 bytes of SRAM, which is above the bootrom stack. */
    BOOT2(rx) : ORIGIN = 0x20041f00, LENGTH = 252
    CRC(rx)   : ORIGIN = ORIGIN(BOOT2) + LENGTH(BOOT2), LENGTH = 4
}

SECTIONS {
    . = ORIGIN(BOOT2);

    .text : {

        __text_start = .;
        *(.text)
        __text_end = .;
        . = __text_start + LENGTH(BOOT2);

    } > BOOT2 =0x00

    .data : {

        __data_start = .;
        . = __data_start + LENGTH(CRC);
        __data_end = .;
        
    } > CRC =0x00
}
