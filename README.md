# Computer Vision Challenge - SoSe 2022
Coding Challenge für die Computer Vision an der TUM.

#toolbox
GUI Layout Toolbox                                    Version 2.3.5       (R2020b)
Image Processing Toolbox                              Version 11.5        (R2022a)
Mapping Toolbox                                       Version 5.3         (R2022a)
Symbolic Math Toolbox                                 Version 9.1         (R2022a)

# Vorbereitung vor der Ausführung des Programms
Öffnen Sie Matlab R2022a
Nehmen Sie die linke obere Ecke des Bildes als Nullpunkt. Nach rechts ist die positive Richtung der x-Achse und nach unten ist die positive Richtung der y-Achse.
Ausgehend vom linken Scheitelpunkt des Rechtecks, der im Uhrzeigersinn durch die Punkte 1, 2, 3 bzw. 4 definiert ist.

RUN main.m
RUN GUI.m
    Drücken Sie 'path', um ein Bild auszuwählen
    Drücken Sie 'ok'
    Drücken Sie 'spider mesh'
    Wählen Sie zwei Punkte im Bild, wählen Sie dann einen Fluchtpunkt und drücken Sie 'enter'
    Stellen Sie die Ansicht mit den Tasten('left','right','back','foward','up','down')

## main.m
         (1)function switch
   
         (2) TIP_GUI
                    find_corner
                               find_line_x
                               find_line_y
         (3) TIP_get5rects
   
         (4) Comput_H

### (1) function switch

Um die Anzahl der Dateien zu reduzieren, werden verschiedene Funktionen in main.m eingebettet und von GUI.m über anonyme Funktionshandles aufgerufen.

cv.TIP_GUI=@TIP_GUI;
cv.find_corner=@find_corner;
cv.find_line_x=@find_line_x;
cv.find_line_y=@find_line_y;
cv.TIP_GUI=@TIP_GUI;
cv.TIP_get5rects=@TIP_get5rects;
cv.computeH=@computeH;

### (2) TIP_GUI

vx,vy:    Koordinaten des Fluchtpunktes
          Auswahl auf dem Bild durch *ginput(1)*

irx,iry:  Koordinaten des inneren Rechtecks 
          Auswahl auf dem Bild durch *ginput(2)*
          Das innere Rechteck kann durch Verbinden der 5 Punkte durch *plot* gezeichnet werden.
          (irx(1),iry(1))-->(irx(2),iry(1))-->(irx(2),iry(2))-->(irx(1),iry(2))-->(irx(1),iry(1))

orx,ory:  Koordinaten des äußeren Rechtecks
          
          Die Punkte des äußeren Rechtecks werden mit Hilfe *find_corner* ,*find_line_x* ,*find_line_y* berechnet.
          *plot*: Das äußere Rechteck wird gezeichnet und die Linien werden erstellt: 
                                                                            (vx,vy)-->(irx(1),iry(1))-->(orx(1),ory(1))
                                                                            (vx,vy)-->(irx(2),iry(1))-->(orx(2),ory(1))
                                                                            (vx,vy)-->(irx(2),iry(2))-->(orx(2),ory(2))
                                                                            (vx,vy)-->(irx(1),iry(2))-->(orx(1),ory(2)) 
**Das Bild ist nun in 5 Rechtecke unterteilt**  


### (3) TIP_get5rects
lmargin : links Grenze
rmargin : rechts Grenze
tmargin : obere Grenze
bmargin : untere Grenze
Erstelle ein neues Bild mit *zeros*, wobei alle Punkte auf 0 gesetzt werden. Fügen Sie das Originalbild in das neue Bild ein und füllen Sie die verbleibenden Positionen mit 1.
Aktualisierung die Position des Punktes im neuen Bild.

Beispiel:ceiling
         Die vier Punkte der Decke sind or1,or2,ir2,ir1.
         Wenn der y-Wert von or1 kleiner ist als der von or2, ist die Verbindungslinie zwischen den beiden Punkten in diesem Punkt diagonal. Lassen Sie also nur den y-Wert von or1 gleich dem von or2 sein und berechnen Sie den x-Wert von or1 mit Hilfe der Funktion *find_line_x* neu.    

**Auf ähnliche Weise lassen sich die Positionen der anderen Rechtecke ermitteln**                    
                              
### (4) Comput_H

https://blog.csdn.net/liubing8609/article/details/85340015
https://codeantenna.com/a/3quvPaH3Hb
https://blog.csdn.net/liubing8609/article/details/85340015
https://zhuanlan.zhihu.com/p/74597564


*maketform*:
            Abbildung eines Quadrats auf ein unregelmäßiges Viereck durch eine Projektionstransformation

## GUI.m

*imtransform*：
            B = imtransform(A,tform) transformiert Bild A gemäß der durch tform definierten 2-D-Raumtransformation und gibt das transformierte Bild B zurück.

*warp*：
            warp(X,map) zeigt das indizierte Bild X mit Farbkarte als Texturkarte auf einer einfachen rechteckigen Fläche an.
            Projizieren Sie alle Punkte auf die entsprechende Ebene.
            https://www.cnblogs.com/tiandsp/p/3819013.html

*camdoly*：
            camdolly(dx,dy,dz,'fixtarget') 'fixtarget' - bewegt nur die Kamera.
            
## Probleme

1.Die Vordergrundobjekte in dem Bild nicht ausschnitten.
2.Wenn der Benutzer das innere Rechteck und den Fluchtpunkt nicht sinnvoll auswählt, dann gibt es auf der Ebene einige schwarze Bereiche, die das Programm nicht wahrnimmt und dementsprechend nicht anpasst. 
3.Es gibt in unserem Programm keinen Schwelle für die Stellung der Ansicht. Wenn der Benutzer die Ansicht zu groß stellt, werden einige Ebene umgedreht.

## reference
https://github.com/yli262/tour-into-the-picture
http://graphics.cs.cmu.edu/courses/15-463/2007_fall/hw/proj5/
http://graphics.cs.cmu.edu/courses/15-463/2007_fall/hw/proj5/code/
