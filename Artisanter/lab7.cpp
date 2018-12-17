#include "stdafx.h"
#include "FinalLab.h"
#include <vector>
#include <Windows.h>
#include <windowsx.h>
#define MAX_LOADSTRING 100
#define IDC_CLEARBUTTON 119
// Глобальные переменные:
HINSTANCE hInst;                                // текущий экземпляр
WCHAR szWindowClass[MAX_LOADSTRING];            // имя класса главного окна

std::vector<std::pair<int, int>> points;

void Draw(HDC, std::vector<std::pair<int, int>>);
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
	LoadStringW(hInstance, IDC_FINALLAB, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);
	// Выполнить инициализацию приложения:
	if (!InitInstance(hInstance, nCmdShow))
	{
		return FALSE;
	}
	HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_FINALLAB));
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
	return (int)msg.wParam;
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
	wcex.style = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc = WndProc;
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = NULL;
	wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = NULL;
	wcex.lpszClassName = szWindowClass;
	wcex.hIconSm = NULL;
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
	HWND hWnd = CreateWindowW(szWindowClass, L"Iron Army | Lab7", WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);
	HWND hWndButton = CreateWindow(_T("BUTTON"), _T("Clear"), WS_CHILD | WS_VISIBLE, 10, 10,
		100, 40, hWnd, (HMENU)IDC_CLEARBUTTON, hInst, NULL);
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
		points.push_back(std::pair<int, int>(XPos, YPos));
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
void Draw(HDC hdc, std::vector<std::pair<int, int>> points)
{
	HPEN hPen = CreatePen(PS_NULL, 0, RGB(0, 0, 0));
	SelectObject(hdc, hPen);

	HBRUSH hRedBrush, hYellowBrush, hBrownBrush;
	hYellowBrush = CreateSolidBrush(RGB(255, 224, 7));
	hBrownBrush = CreateSolidBrush(RGB(20, 0, 0));
	hRedBrush = CreateSolidBrush(RGB(233, 46, 57));

	for (int i = 0; i < points.size(); i++)
	{
		int x = points[i].first;
		int y = points[i].second;



		SelectObject(hdc, hRedBrush);
		Rectangle(hdc, x - 34, y - 50, x + 34, y + 45);
		SelectObject(hdc, hYellowBrush);
		Rectangle(hdc, x - 26, y + 44, x - 6, y + 80);
		Rectangle(hdc, x + 6, y + 44, x + 26, y + 80);

		Rectangle(hdc, x - 42, y - 44, x - 28, y + 25);
		Rectangle(hdc, x + 28, y - 44, x + 42, y + 25);

		Rectangle(hdc, x - 20, y - 86, x + 20, y - 44);
		Rectangle(hdc, x - 22, y - 76, x + 22, y - 62);
		
		Ellipse(hdc, x - 13, y - 32, x + 13, y - 6);

		SelectObject(hdc, hRedBrush);
		Rectangle(hdc, x - 50, y + 9, x - 32, y + 27);
		Rectangle(hdc, x + 32, y + 9, x + 50, y + 27);

		Rectangle(hdc, x - 29, y + 79, x - 3, y + 114);
		Rectangle(hdc, x + 3, y + 79, x + 29, y + 114);

		Pie(hdc, x - 22, y - 102, x + 22, y - 52, x + 20, y - 86, x - 20, y - 86);
	
		SelectObject(hdc, hBrownBrush);
		Rectangle(hdc, x - 15, y - 71, x - 5, y - 67);
		Rectangle(hdc, x + 5, y - 71, x + 15, y - 67);

		Rectangle(hdc, x - 8, y - 54, x + 8, y - 50);

	}
	DeleteObject(hRedBrush);
	DeleteObject(hYellowBrush);
	DeleteObject(hBrownBrush);
}