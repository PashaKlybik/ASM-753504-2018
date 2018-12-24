#include <windows.h>
#include "resource.h"

#define ID_BTN 12

const char g_szClassName[] = "myWindowClass";
const int ID_TIMER = 1;

const int EMP_X = 10;
const int EMP_Y = 33;
const int WORKSPACE_EMP_Y = 91;
const int TRAIN_D = 2;

bool isDrawn = false;

typedef struct _TrainInfo
{
    int width;
    int height;
    int x;
    int y;

    int dx;
    int dy;
} TrainInfo;

TrainInfo trainInfo;
HICON hIcon = NULL;
HBITMAP ballImage = NULL;
HBITMAP backgroundImage = NULL;

void ClearWorkspace(HWND hwnd)
{
    RECT a;
    a.bottom = 507;
    a.left = 0;
    a.right = 500;
    a.top = 0;
    InvalidateRect(hwnd, &a, true);
}

void UpdateBallPosition(RECT* prc)
{
    trainInfo.x += trainInfo.dx;
    trainInfo.y += trainInfo.dy;

    if (trainInfo.x < 0) {
        trainInfo.x = 0;
        trainInfo.dx = TRAIN_D;
    } else if (trainInfo.x + trainInfo.width > prc->right) {
        trainInfo.x = prc->right - trainInfo.width;
        trainInfo.dx = -TRAIN_D;
    }

    if(trainInfo.y < 0) {
        trainInfo.y = 0;
        trainInfo.dy = TRAIN_D;
    } else if(trainInfo.y + trainInfo.height > prc->bottom - WORKSPACE_EMP_Y) {
        trainInfo.y = prc->bottom - WORKSPACE_EMP_Y - trainInfo.height;
        trainInfo.dy = -TRAIN_D;
    }
}

void DrawBitmap(HWND hwnd, int x, int y, HBITMAP pic)
{
    BITMAP bm;
    PAINTSTRUCT ps;

    HDC hdc = BeginPaint(hwnd, &ps);

    HDC hdcMem = CreateCompatibleDC(hdc);
    HBITMAP hbmOld = (HBITMAP)SelectObject(hdcMem, pic);

    GetObject(pic, sizeof(bm), &bm);

    BitBlt(hdc, x, y, bm.bmWidth, bm.bmHeight, hdcMem, 0, 0, SRCCOPY);

    SelectObject(hdcMem, hbmOld);
    DeleteDC(hdcMem);

    EndPaint(hwnd, &ps);
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    switch(msg) {
        case WM_CREATE: {
            hIcon = LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(MYICON));
            SendMessage(hwnd, WM_SETICON, ICON_BIG, (LPARAM)hIcon);

            ballImage = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(BALL));
            if(ballImage == NULL)
                MessageBox(hwnd, "Could not load image!", "Error", MB_OK | MB_ICONEXCLAMATION);

            backgroundImage = LoadBitmap(GetModuleHandle(NULL), MAKEINTRESOURCE(IDB_YEAR));

            CreateWindow("BUTTON",
                      "CLEAR",
                      WS_VISIBLE | WS_CHILD | WS_BORDER,
                      20, 550, 100, 20,
                      hwnd, (HMENU) 1, NULL, NULL);

            CreateWindow("BUTTON",
                      "CLOSE",
                      WS_VISIBLE | WS_CHILD | WS_BORDER,
                      350, 550, 100, 20,
                      hwnd, (HMENU) ID_BTN, NULL, NULL);
        }
        break;

        case WM_COMMAND: {
            switch (LOWORD(wParam)) {
                case 1: {
                    if (isDrawn) {
                        KillTimer(hwnd, ID_TIMER);
                        ClearWorkspace(hwnd);
                        isDrawn = false;
                    }
                }
                break;

                case ID_BTN:{
                    DestroyWindow(hwnd);
                    break;
                }
            }
        }
        break;

        case WM_LBUTTONDOWN: {
            if (!isDrawn) {
                UINT ret;
                BITMAP bm;
                GetObject(ballImage, sizeof(bm), &bm);
                ZeroMemory(&trainInfo, sizeof(trainInfo));
                trainInfo.width = bm.bmWidth;
                trainInfo.height = bm.bmHeight;

                POINT cursorPos;
                RECT pos;
                GetCursorPos(&cursorPos);
                float x = cursorPos.x, y = cursorPos.y;
                GetWindowRect(hwnd, &pos);
                float a = pos.left, b = pos.top;
                trainInfo.x = x - a - EMP_X - trainInfo.width / 2;
                trainInfo.y = y - b - EMP_Y - trainInfo.height / 2;

                trainInfo.dx = TRAIN_D;
                trainInfo.dy = TRAIN_D;

                SetTimer(hwnd, ID_TIMER, 10, NULL);
                isDrawn = true;
            } else {
                KillTimer(hwnd, ID_TIMER);

            }
        }
        break;

        case WM_CLOSE:
            DestroyWindow(hwnd);
        break;

        case WM_PAINT: {
            DrawBitmap(hwnd, 0, 507, backgroundImage);
        }
        break;

        case WM_TIMER: {
            RECT rcClient;
            GetClientRect(hwnd, &rcClient);
            UpdateBallPosition(&rcClient);
            ClearWorkspace(hwnd);
            DrawBitmap(hwnd, trainInfo.x, trainInfo.y, ballImage);
        }
        break;

        case WM_DESTROY: {
            KillTimer(hwnd, ID_TIMER);
            DeleteObject(ballImage);
            DeleteObject(backgroundImage);
            DeleteObject(hIcon);
            PostQuitMessage(0);
        }
        break;

        default:
            return DefWindowProc(hwnd, msg, wParam, lParam);
    }
    return 0;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    LPSTR lpCmdLine, int nCmdShow)
{
    WNDCLASSEX wc;
    HWND hwnd;
    MSG Msg;

    wc.cbSize        = sizeof(WNDCLASSEX);
    wc.style         = 0;
    wc.lpfnWndProc   = WndProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hInstance;
    wc.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
    wc.lpszMenuName  = NULL;
    wc.lpszClassName = g_szClassName;
    wc.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);
    RegisterClassEx(&wc);

    hwnd = CreateWindowEx(
        WS_EX_CLIENTEDGE,
        g_szClassName,
        "NEW YEAR",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 500, 650,
        NULL, NULL, hInstance, NULL);

    ShowWindow(hwnd, nCmdShow);
    UpdateWindow(hwnd);

    while(GetMessage(&Msg, NULL, 0, 0) > 0) {
        TranslateMessage(&Msg);
        DispatchMessage(&Msg);
    }
    return Msg.wParam;
}
