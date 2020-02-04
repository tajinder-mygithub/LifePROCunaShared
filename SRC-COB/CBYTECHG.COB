01FF02 @OPTIONS BINARY(BYTE)
       IDENTIFICATION DIVISION.
       PROGRAM-ID.     CBYTECHG.
       DATE-WRITTEN.
       DATE-COMPILED.
      *@**20100811*******************************************
      *@** 
      *@** Licensed Materials - Property of
      *@** ExlService Holdings, Inc.
      *@**  
      *@** (C) 1983-2010 ExlService Holdings, Inc.  All Rights Reserved.
      *@** 
      *@** Contains confidential and trade secret information.  
      *@** Copyright notice is precautionary only and does not
      *@** imply publication.
      *@** 
      *@**20100811*******************************************


      *D****************************************************************
      *D                     Program Description
      *D****************************************************************
      *D
      *D This program is a 15.x replacement for CBYTECHG, which, in 
      *D prior versions, was written in C and performed a byte conversion
      *D process for binary typed fields.  .NET requires this "stub" 
      *D program that simply moves input to output.   
      *D However, in the cases of Vconverts, a change has been made to 
      *D have this do the byte conversion, but using NetCOBOl techniques. 
      *D
      *D****************************************************************
      *H****************************************************************
      *H                        Program History
      *H****************************************************************
081808*H 20080402-003-01 DAR  Created as a new program for 15.x.  
010709*H 20090108-004-01 DAR  Rewrite for efficiency.  
      *H
      *H****************************************************************

      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.

       SOURCE-COMPUTER. IBM-AT.
       OBJECT-COMPUTER. IBM-AT.

       REPOSITORY.
           CLASS CLASS-BYTE-ARRAY AS "System.Byte[]"
           CLASS CLASS-BYTE AS "System.Byte".

       SPECIAL-NAMES.
           ARGUMENT-NUMBER IS NUM-ARGS
           ARGUMENT-VALUE  IS ARG-VAL
           ENVIRONMENT-NAME  IS ENV-NAME
           ENVIRONMENT-VALUE IS ENV-VAL.


      ******************************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       COPY WWSCRCPY.


       COPY WGLB2CPY.

       01  WS-PGUIPROG-VALUE           PIC X(40) VALUE SPACES.
       01  WS-ENV-PGUIPROG.
           05 FILLER                   PIC X(08) VALUE 'PGUIPROG'.
           05 FILLER                   PIC X(01) VALUE LOW-VALUES.

       01  DO-CONVERSIONS-FLAG         PIC X(01).
           88  DO-CONVERSIONS          VALUE 'Y'.
           88  NOT-DO-CONVERSIONS      VALUE 'N'.
       01  RETRIEVED-ENVIRONMENT-FLAG  PIC X(01).
           88  RETRIEVED-ENVIRONMENT   VALUE 'Y'.

       01  WS-DIGIT1                  PIC 9 COMP-5.
       01  WS-DIGIT2                  PIC 9 COMP-5.
       01  SINGLE-CHAR.
           05  WS-CHAR-X              PIC X(01).
           05  WS-CHAR-N REDEFINES WS-CHAR-X
                                      PIC 9 COMP-5.

       01  SUB1                       PIC S9(04) COMP-5.
       01  SUB2                       PIC S9(04) COMP-5.
       01  WS-DOUBLE-SIZE             PIC 9(04).
       01  WS-QUOTIENT                PIC 9(04).

      ******************************************************************
       LINKAGE SECTION.
      ******************************************************************

       01  WCBYTE-FUNCTION               PIC X(01).
           88  WCBYTE-BINARY-TO-CHAR       VALUE 'B'.
           88  WCBYTE-CHAR-TO-BINARY       VALUE 'C'.
       01  WCBYTE-BUFFER-SIZE            PIC S9(04) COMP-5.
       01  WCBYTE-INPUT-BUFFER           PIC X(WGLB2-DA-LEN2).
       01  WCBYTE-OUTPUT-BUFFER          PIC X(WGLB2-DA-LEN2).
       01  WCBYTE-RETURN-CODE            PIC S9(04) COMP-5.
           88  WCBYTE-RETURN-OK          VALUE 0.

      ******************************************************************
       PROCEDURE DIVISION USING WCBYTE-FUNCTION,
                                WCBYTE-BUFFER-SIZE,
                                WCBYTE-INPUT-BUFFER,
                                WCBYTE-OUTPUT-BUFFER
                          RETURNING
                                WCBYTE-RETURN-CODE.

      ******************************************************************
       MAINLINE.

           IF NOT RETRIEVED-ENVIRONMENT
               SET NOT-DO-CONVERSIONS TO TRUE
               DISPLAY WS-ENV-PGUIPROG UPON ENV-NAME
               ACCEPT WS-PGUIPROG-VALUE      FROM ENV-VAL
                   ON EXCEPTION
                       MOVE SPACES         TO WS-PGUIPROG-VALUE
               END-ACCEPT

               IF WS-PGUIPROG-VALUE = 'VDRVRPRG'
                   SET DO-CONVERSIONS TO TRUE
               END-IF
               SET RETRIEVED-ENVIRONMENT TO TRUE
           END-IF.


           IF NOT DO-CONVERSIONS
           OR WCBYTE-BINARY-TO-CHAR
      *        Binary to Char conversions are not needed, but calls to CBYTECHG remain.      
               MOVE WCBYTE-INPUT-BUFFER TO WCBYTE-OUTPUT-BUFFER
           ELSE

      *        Currently this is not used at all, but it is tested.  
               IF WCBYTE-BINARY-TO-CHAR
                   MOVE SPACES TO WCBYTE-OUTPUT-BUFFER

                   MOVE -1 TO SUB1
                   MOVE -1 TO SUB2
                   PERFORM WCBYTE-BUFFER-SIZE TIMES

                       ADD 1 TO SUB2
                       ADD 1 TO SUB1
                       MOVE WCBYTE-INPUT-BUFFER (SUB1 + 1:1)
                              TO WS-CHAR-X
                       IF WS-CHAR-N NOT < 65
                           SUBTRACT 55 FROM WS-CHAR-N
                                GIVING WS-DIGIT1
                       ELSE
                           SUBTRACT 48 FROM WS-CHAR-N
                                GIVING WS-DIGIT1
                       END-IF

                       ADD 1 TO SUB1
                       MOVE WCBYTE-INPUT-BUFFER (SUB1 + 1:1)
                              TO WS-CHAR-X

                       IF WS-CHAR-N NOT < 65
                           SUBTRACT 55 FROM WS-CHAR-N
                                GIVING WS-DIGIT2
                       ELSE
                           SUBTRACT 48 FROM WS-CHAR-N
                                GIVING WS-DIGIT2
                       END-IF

                       COMPUTE WS-CHAR-N = ( WS-DIGIT1 * 16 )
                                + WS-DIGIT2

                       MOVE WS-CHAR-X
                          TO WCBYTE-OUTPUT-BUFFER (SUB2 + 1:1)

                   END-PERFORM


               ELSE
      *            Assume Char to Binary 

                   MOVE SPACES TO WCBYTE-OUTPUT-BUFFER

                   MOVE -1 TO SUB1
                   MOVE -1 TO SUB2
                   PERFORM WCBYTE-BUFFER-SIZE TIMES
                       ADD 1 TO SUB2

                       MOVE WCBYTE-INPUT-BUFFER (SUB2 + 1:1)
                            TO WS-CHAR-X

                       DIVIDE WS-CHAR-N BY 16 GIVING WS-DIGIT1
                                       REMAINDER WS-DIGIT2

                       IF (WS-DIGIT1 NOT < 10 AND
                           WS-DIGIT1 NOT > 15)
                           COMPUTE WS-DIGIT1 = WS-DIGIT1 + 55
                       ELSE
                           COMPUTE WS-DIGIT1 = WS-DIGIT1 + 48
                       END-IF

                       ADD 1 TO SUB1

                       MOVE WS-DIGIT1 TO WS-CHAR-N
                       MOVE WS-CHAR-X
                           TO WCBYTE-OUTPUT-BUFFER(SUB1 + 1:1)

                       IF (WS-DIGIT2 NOT < 10 AND
                           WS-DIGIT2 NOT > 15)
                           COMPUTE WS-DIGIT2 = WS-DIGIT2 + 55
                       ELSE
                           COMPUTE WS-DIGIT2 = WS-DIGIT2 + 48
                       END-IF

                       ADD 1 TO SUB1
                       MOVE WS-DIGIT2 TO WS-CHAR-N
                       MOVE WS-CHAR-X
                           TO WCBYTE-OUTPUT-BUFFER(SUB1 + 1:1)


                   END-PERFORM
               END-IF.

           GOBACK.


      ******************************************************************

