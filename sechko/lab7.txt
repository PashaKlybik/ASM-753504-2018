#if defined(UNICODE) && !defined(_UNICODE)
    #define _UNICODE
#elif defined(_UNICODE) && !defined(UNICODE)
    #define UNICODE
#endif

#define ID_BTN 0

#include <iostream>
#include <tchar.h>
#include <windows.h>

/*  Declare Windows procedure  */
LRESULT CALLBACK WindowProcedure (HWND, UINT, WPARAM, LPARAM);


/*  Make the class name into a global variable  */
TCHAR szClassName[] = "CodeBlocksWindowsApp";
TCHAR path[] = "kappa.bmp";

bool LoadAndBlitBitmap(LPCSTR, HDC, int, int);


int WINAPI WinMain (HINSTANCE hThisInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR lpszArgument,
                     int nCmdShow)
{
    HWND hwnd;               /* This is the handle for our window */
    MSG messages;            /* Here messages to the application are saved */
    WNDCLASSEX wincl;        /* Data structure for the windowclass */

    /* The Window structure */
    wincl.hInstance = hThisInstance;
    wincl.lpszClassName = szClassName;
    wincl.lpfnWndProc = WindowProcedure;      /* This function is called by windows */
    wincl.style = CS_DBLCLKS;                 /* Catch double-clicks */
    wincl.cbSize = sizeof (WNDCLASSEX);

    /* Use default icon and mouse-pointer */
    wincl.hIcon = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hIconSm = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hCursor = LoadCursor (NULL, IDC_ARROW);
    wincl.lpszMenuName = NULL;                 /* No menu */
    wincl.cbClsExtra = 0;                      /* No extra bytes after the window class */
    wincl.cbWndExtra = 0;                      /* structure or the window instance */
    /* Use Windows's default colour as the background of the window */
    wincl.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);

    /* Register the window class, and if it fails quit the program */
    if (!RegisterClassEx (&wincl)){
        MessageBox(NULL, "Unable to register class", "Error", MB_OK);
        return 0;
    }

    /* The class is registered, let's create the program*/
    hwnd = CreateWindowEx (
           0,                   /* Extended possibilites for variation */
           szClassName,         /* Classname */
           _T("Lab7"),       /* Title Text */
           WS_OVERLAPPEDWINDOW, /* default window */
           CW_USEDEFAULT,       /* Windows decides the position */
           CW_USEDEFAULT,       /* where the window ends up on the screen */
           800,                 /* The programs width */
           800,                 /* and height in pixels */
           HWND_DESKTOP,        /* The window is a child-window to desktop */
           NULL,                /* No menu */
           hThisInstance,       /* Program Instance handler */
           NULL                 /* No Window Creation data */
           );

    if (!hwnd){
        MessageBox(NULL, "Unable to create window!", "Error", MB_OK);
        return 0;
    }

    /* Make the window visible on the screen */
    ShowWindow (hwnd, nCmdShow);
    UpdateWindow(hwnd);

    /* Run the message loop. It will run until GetMessage() returns 0 */
    while (GetMessage (&messages, NULL, 0, 0))
    {
        /* Translate virtual-key messages into character messages */
        TranslateMessage(&messages);
        /* Send message to WindowProcedure */
        DispatchMessage(&messages);
    }

    /* The program return-value is 0 - The value that PostQuitMessage() gave */
    return messages.wParam;
}


/*  This function is called by the Windows function DispatchMessage()  */

LRESULT CALLBACK WindowProcedure (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
    PAINTSTRUCT ps;
    POINT p;
    HWND button;
    switch (message)                  /* handle the messages */
    {
        case WM_CREATE:
            button = CreateWindow("button", "Delete",
                                  WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON, 10, 10, 100, 30,
                                  hwnd, (HMENU) ID_BTN, NULL, NULL);
            break;
        case WM_COMMAND:
            switch(LOWORD(wParam)){
                case ID_BTN:{
                    InvalidateRect(hwnd, NULL, true);
                    UpdateWindow(hwnd);
                    break;
                }
            }
            break;
        case WM_PAINT:
            break;
        case WM_LBUTTONDOWN:
            hdc = BeginPaint(hwnd, &ps);
            GetCursorPos(&p);
            std::cout<<p.x<<" "<<p.y<<"\n";
            ScreenToClient(hwnd, &p);
            std::cout<<p.x<<" "<<p.y<<"\n";
            LoadAndBlitBitmap(path, hdc, p.x-150, p.y-150);
            InvalidateRect(hwnd, NULL, false);
            EndPaint(hwnd, &ps);
            UpdateWindow(hwnd);
            break;
        case WM_DESTROY:
            PostQuitMessage (0);       /* send a WM_QUIT to the message queue */
            break;
        default:                      /* for messages that we don't deal with */
            return DefWindowProc (hwnd, message, wParam, lParam);
    }

    return 0;
}

bool LoadAndBlitBitmap(LPCSTR path, HDC hWinDC, int x, int y)
{
    HBITMAP hOldBmp;
	HBITMAP hBitmap;
	BITMAP bitmap;
	HDC hLocalDC;
	hBitmap = (HBITMAP)LoadImage(NULL, path, IMAGE_BITMAP, 0, 0,
		LR_LOADFROMFILE);

	hLocalDC = CreateCompatibleDC(hWinDC);
	hOldBmp = (HBITMAP)SelectObject(hLocalDC, hBitmap);
	BitBlt(hWinDC, x, y, bitmap.bmWidth, bitmap.bmHeight,
		hLocalDC, 0, 0, SRCCOPY);

	DeleteDC(hLocalDC);
	DeleteObject(hBitmap);
	return true;
}
