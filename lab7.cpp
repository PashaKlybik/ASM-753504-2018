// WindowsProject.cpp : Определяет точку входа для приложения.
//

#include "stdafx.h"
#include "WindowsProject.h"
#include <vector>
#include <Windows.h>
#include <windowsx.h>


#define MAX_LOADSTRING 100
#define IDC_CLEARBUTTON 119

// Глобальные переменные:
HINSTANCE hInst;                                // текущий экземпляр
WCHAR szWindowClass[MAX_LOADSTRING];            // имя класса главного окна
std::vector<std::pair<int,std::pair<int, int>>> points;
int needToDraw = 1;
void Draw(HDC, std::vector<std::pair<int, std::pair<int, int>>>);

// Отправить объявления функций, включенных в этот модуль кода:
ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

    // Инициализация глобальных строк
    LoadStringW(hInstance, IDC_WINDOWSPROJECT, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);

    // Выполнить инициализацию приложения:
    if (!InitInstance (hInstance, nCmdShow))
    {
        return FALSE;
    }

    HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_WINDOWSPROJECT));

    MSG msg;

    // Цикл основного сообщения:
    while (GetMessage(&msg, nullptr, 0, 0))
    {
        if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }

    return (int) msg.wParam;
}

//
//  ФУНКЦИЯ: MyRegisterClass()
//
//  ЦЕЛЬ: Регистрирует класс окна.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = NULL;
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = NULL;
    wcex.lpszClassName  = szWindowClass;
    wcex.hIconSm        = NULL;

    return RegisterClassExW(&wcex);
}

//
//   ФУНКЦИЯ: InitInstance(HINSTANCE, int)
//
//   ЦЕЛЬ: Сохраняет маркер экземпляра и создает главное окно
//
//   КОММЕНТАРИИ:
//
//        В этой функции маркер экземпляра сохраняется в глобальной переменной, а также
//        создается и выводится главное окно программы.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; // Сохранить маркер экземпляра в глобальной переменной

   HWND hWnd = CreateWindowW(szWindowClass, L"Canvas | Lab7", WS_OVERLAPPEDWINDOW,
       CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

   HWND hWndButton = CreateWindow(_T("BUTTON"),_T("Clear"),WS_CHILD | WS_VISIBLE, 0, 0,
	   100, 25, hWnd, (HMENU)IDC_CLEARBUTTON, hInst, NULL);

   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

//
//  ФУНКЦИЯ: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  ЦЕЛЬ: Обрабатывает сообщения в главном окне.
//
//  WM_COMMAND  - обработать меню приложения
//  WM_PAINT    - Отрисовка главного окна
//  WM_DESTROY  - отправить сообщение о выходе и вернуться
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
	case WM_LBUTTONDOWN:
	{
			int XPos = GET_X_LPARAM(lParam);
			int YPos = GET_Y_LPARAM(lParam);
			points.push_back(std::pair<int, std::pair<int, int>>
				(needToDraw, std::pair<int, int>(XPos, YPos)));
			InvalidateRect(hWnd, 0, TRUE);
	}
	break;
    case WM_COMMAND:
        {
			switch (LOWORD(wParam))
			{
			case IDC_CLEARBUTTON:
				points.clear();
				InvalidateRect(hWnd, NULL, TRUE);
				break;
			}
        }
        break;
    case WM_PAINT:
        {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hWnd, &ps);
			Draw(hdc, points);
            EndPaint(hWnd, &ps);
        }
        break;
    case WM_DESTROY:
        PostQuitMessage(0);
        break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

void Draw(HDC hdc, std::vector<std::pair<int, std::pair<int, int>>> points)
{
	HPEN hWhitePen, hBlackPen, hBluePen;
	HBRUSH hBlueBrush;
	hWhitePen = CreatePen(PS_SOLID, 2, RGB(255, 255, 255));
	hBluePen = CreatePen(PS_SOLID, 1, RGB(0, 9, 173));
	hBlackPen = CreatePen(PS_SOLID, 1, RGB(0, 0, 0));
	hBlueBrush = CreateSolidBrush(RGB(0, 9, 173));

	for (int i = 0; i < points.size(); i++)
	{
		int x = points[i].second.first;
		int y = points[i].second.second;

		SelectObject(hdc, hBlueBrush);
		SelectObject(hdc, hBlackPen);
		Rectangle(hdc, x - 40, y - 50, x + 40, y + 50);

		SelectObject(hdc, hWhitePen);
		MoveToEx(hdc, x - 35, y, NULL);
		LineTo(hdc, x, y - 40);
		LineTo(hdc, x, y);
		LineTo(hdc, x + 30, y - 21);
		LineTo(hdc, x + 30, y + 1);
		MoveToEx(hdc, x - 11, y - 18, NULL);
		LineTo(hdc, x - 11, y);
		LineTo(hdc, x + 12, y - 21);
		LineTo(hdc, x + 12, y);

		MoveToEx(hdc, x - 5, y + 15, NULL);
		LineTo(hdc, x - 20, y + 15);
		LineTo(hdc, x - 20, y + 35);
		LineTo(hdc, x - 5, y + 35);
		LineTo(hdc, x - 5, y + 25);
		LineTo(hdc, x - 20, y + 25);

		MoveToEx(hdc, x + 5, y + 15, NULL);
		LineTo(hdc, x + 5, y + 25);
		LineTo(hdc, x + 20, y + 25);
		MoveToEx(hdc, x + 20, y + 15, NULL);
		LineTo(hdc, x + 20, y + 35);	

		MoveToEx(hdc, x + 30, y + 15, NULL);
		LineTo(hdc, x + 30, y + 18);
	}
	DeleteObject(hBlackPen);
	DeleteObject(hWhitePen);
	DeleteObject(hBluePen);
	DeleteObject(hBlueBrush);
}
